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

    var list: std.ArrayList(Task) = .empty;
    defer list.deinit(allocator); // free memory from heap

    // clean string memory on exit
    defer {
        for (list.items) |item| {
            allocator.free(item.task_name);
        }
    }

    // loop variables
    var run: bool = true;
    var id: u64 = 0;

    while (run) {
        try stdout.writeAll("Task List (1. list task, 2. add task, 3. remove task)\n");
        try stdout.flush(); // critical in zig 16.0

        const line = try stdin.takeDelimiterExclusive('\n');
        stdin.toss(1);

        // test the read output
        // try stdout.print("{s}", .{line});

        // if loop logic
        switch (Command.parse(line)) {
            .list => {
                for (list.items) |item| {
                    const task_id = item.getTaskId();
                    const name = item.getTaskName();
                    std.debug.print("{d}: {s}\n", .{ task_id, name });
                }
            },
            .add => {
                // request task name
                try stdout.writeAll("Enter Task: ");
                try stdout.flush();

                // get task name
                const entry = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);

                // fix: copy string out of temp. ring buffer ~ whatever that means
                const saved_name = try allocator.dupe(u8, entry);

                // create task object
                const temp = Task{ .task_id = id, .task_name = saved_name };

                // append
                try list.append(allocator, temp);
                id = id + 1;

                // confirmation
                std.debug.print("\nTask Added.\n", .{});
            },
            .remove => {
                // request id to remove
                try stdout.writeAll("Enter ID to Remove: ");
                try stdout.flush();

                // get id
                const entry = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);

                const saved_id = try std.fmt.parseInt(i64, entry, 10);
                var index: i64 = 0;

                for (list.items) |item| {
                    if (item.getTaskId() == saved_id) {
                        const list_index: usize = @intCast(index);

                        // free from heap
                        allocator.free(list.items[list_index].task_name);

                        // remove struct from list safely
                        _ = list.orderedRemove(list_index);
                    }
                    index = index + 1;
                }
            },
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
    pub fn getTask(self: *const Task) Task {
        return Task{
            .task_id = self.task_id,
            .task_name = self.task_name,
        };
    }

    pub fn editTask(self: *Task, new_name: []const u8) void {
        self.task_name = new_name;
    }

    pub fn getTaskName(self: *const Task) []const u8 {
        return self.task_name;
    }

    pub fn getTaskId(self: *const Task) u64 {
        return self.task_id;
    }
};

const TaskList = struct {
    list_name: []const u8,
    tasks: std.ArrayList(Task) = .empty,
    id: u64 = 0,
    num_tasks: u64 = 0,
    allocator: std.mem.Allocator,

    // functions
    pub fn initTask(list_name: []const u8, allocator: std.mem.Allocator) TaskList {
        return TaskList{ .list_name = list_name, .allocator = allocator };
    }

    // move the tui logic to here?
    pub fn addTask(self: *TaskList, task_name: []const u8) void {
        self.tasks.append(self.allocator, Task{ .task_name = task_name, .task_id = self.id });
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

const Command = enum {
    list,
    add,
    remove,
    exit,
    unknown, // fallback

    pub fn parse(str: []const u8) Command {
        if (std.mem.eql(u8, str, "list")) return .list;
        if (std.mem.eql(u8, str, "add")) return .add;
        if (std.mem.eql(u8, str, "remove")) return .remove;
        if (std.mem.eql(u8, str, "exit")) return .exit;

        return .unknown;
    }
};
