const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // create raw buffer (write) -> stored on the stack
    var out_buf: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &out_buf);
    const stdout = &stdout_writer.interface;

    // setup stdin buffer and reader interface (read) -> stored on the stack
    var in_buf: [1024]u8 = undefined;
    var stdin_reader = std.Io.File.stdin().reader(io, &in_buf);
    const stdin = &stdin_reader.interface;

    const allocator = init.gpa; // -> allocator to the heap

    // TODO Application Init:
    var app = TodoApplication.initApp(allocator);

    // Clean up
    defer app.deinit();

    // loop variables
    var run: bool = true;

    try stdout.writeAll("TodoListMenu\n------------\ncreate\nlist\nadd\nremove\nexit\nunknown\n\n");
    try stdout.flush(); // critical in zig 16.0

    while (run) {
        const line = try stdin.takeDelimiterExclusive('\n');
        stdin.toss(1);

        // clear terminal
        try stdout.writeAll("\x1B[2J\x1B[H");
        try stdout.flush();

        // test the read output
        // try stdout.print("{s}", .{line});

        // if loop logic
        switch (Command.parse(line)) {
            .create => {
                // request task name
                try stdout.writeAll("Enter Todo List Name: ");
                try stdout.flush();

                // get task name
                const entry = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);

                // append
                try app.createTodoList(entry);

                // confirmation
                std.debug.print("\n{s} has been created.\n", .{entry});
            },
            .toggle => {
                // request task name
                app.printLists();
                try stdout.writeAll("Enter Todo List Name: ");
                try stdout.flush();

                // get task name
                const entry = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);

                const res = app.changeSelectedList(entry);

                // handling the exception
                if (res) {
                    // confirmation
                    std.debug.print("\nSelected List is now: {s}.\n", .{entry});
                } else {
                    std.debug.print("\nUnable to resolve list {s}", .{entry});
                }
            },
            .list => {
                app.printCurrentList();
            },
            .add => {
                // request task name
                try stdout.writeAll("Enter Task: ");
                try stdout.flush();

                // get task name
                const entry = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);

                // append
                try app.addTask(entry);

                // confirmation
                std.debug.print("\nTask Added.\n", .{});
            },
            .remove => {},
            .exit => {
                // exit loop
                run = false; // or just break
            },
            .unknown => {
                // print out the unknown command then say thats it's unknown
            },
        }
    }
}

const Task = struct {
    task_id: u64,
    task_name: []const u8,

    // const because no data type edits
    pub fn getTask(self: Task) Task {
        return Task{
            .task_id = self.task_id,
            .task_name = self.task_name,
        };
    }

    pub fn editTask(self: *Task, new_name: []const u8) void {
        self.task_name = new_name;
    }

    pub fn getTaskName(self: Task) []const u8 {
        return self.task_name;
    }

    pub fn getTaskId(self: Task) u64 {
        return self.task_id;
    }
};

const TaskList = struct {
    list_name: []const u8,
    tasks: std.ArrayListUnmanaged(Task) = .empty,
    id: u64 = 0,
    num_tasks: u64 = 0,
    allocator: std.mem.Allocator,

    // functions
    pub fn initTask(list_name: []const u8, allocator: std.mem.Allocator) TaskList {
        return TaskList{ .list_name = list_name, .allocator = allocator };
    }

    pub fn deinit(self: *TaskList) void {
        self.tasks.deinit(self.allocator);
    }

    pub fn getTaskListName(self: TaskList) []const u8 {
        return self.list_name;
    }

    // move the tui logic to here?
    pub fn addTask(self: *TaskList, task_name: []const u8) !void {
        try self.tasks.append(self.allocator, Task{ .task_name = task_name, .task_id = self.id });
        self.id = self.id + 1;
    }

    pub fn removeTaskByName(self: *TaskList, task_name: []const u8) void {
        // iterate through array and search by task_name
        var i = 0;
        for (self.tasks.items) |t| {
            if (std.mem.eql(u8, t.task_name, task_name)) {
                const size: usize = @intCast(i);
                self.tasks.orderedRemove(size);
            }
            i = i + 1;
        }
    }

    pub fn removeTaskById(self: *TaskList, id: u64) void {
        // iterate through array and search by task_name
        var i = 0;
        for (self.tasks.items) |t| {
            if (t.getTaskId() == id) {
                const size: usize = @intCast(i);
                self.tasks.orderedRemove(size);
            }
            i = i + 1;
        }
    }
};

const TodoApplication = struct {
    task_lists: std.ArrayListUnmanaged(TaskList) = .empty,
    allocator: std.mem.Allocator,
    current_list: u64 = 0,

    pub fn initApp(allocator: std.mem.Allocator) TodoApplication {
        return TodoApplication{ .allocator = allocator };
    }

    pub fn deinit(self: *TodoApplication) void {
        for (self.task_lists.items) |*i| {
            i.deinit();
        }

        // deinit
        self.task_lists.deinit(self.allocator);
    }

    pub fn createTodoList(self: *TodoApplication, list_name: []const u8) !void {
        const temp_list = TaskList.initTask(list_name, self.allocator);
        try self.task_lists.append(self.allocator, temp_list);
    }

    pub fn deleteTodoList(self: *TodoApplication, list_name: []const u8) void {
        var index = 0;
        for (self.task_lists.items) |i| {
            if (std.mem.eql(u8, list_name, i.getTaskname())) {
                const list_index: usize = @intCast(index);
                self.task_lists.orderedRemove(list_index);
            }
            index = index + 1;
        }
    }

    pub fn printLists(self: TodoApplication) void {
        var index: u64 = 0;
        for (self.task_lists.items) |i| {
            std.debug.print("{d}: {s}\n", .{ index, i.getTaskListName() });
            index = index + 1;
        }
    }

    pub fn printCurrentList(self: TodoApplication) void {
        //std.debug.print("{d}", .{self.current_list});
        for (self.task_lists.items[self.current_list].tasks.items) |i| {
            std.debug.print("{d}: {s}\n", .{ i.getTaskId(), i.getTaskName() });
        }
    }

    pub fn changeSelectedList(self: *TodoApplication, list_name: []const u8) bool {
        var index: u64 = 0;
        for (self.task_lists.items) |i| {
            if (std.mem.eql(u8, list_name, i.getTaskListName())) {
                self.current_list = index;
                return true;
            }
            index = index + 1;
        }
        return false;
    }

    pub fn addTask(self: *TodoApplication, task_name: []const u8) !void {
        try self.task_lists.items[self.current_list].addTask(task_name);
    }

    // remove
};

const Command = enum {
    create,
    toggle,
    list,
    add,
    remove,
    exit,
    unknown, // fallback

    pub fn parse(str: []const u8) Command {
        if (std.mem.eql(u8, str, "create")) return .create;
        if (std.mem.eql(u8, str, "toggle")) return .toggle;
        if (std.mem.eql(u8, str, "list")) return .list;
        if (std.mem.eql(u8, str, "add")) return .add;
        if (std.mem.eql(u8, str, "remove")) return .remove;
        if (std.mem.eql(u8, str, "exit")) return .exit;

        return .unknown;
    }
};
