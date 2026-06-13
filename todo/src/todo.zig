const std = @import("std");

const SAVE_FILE = "todo_storage.json";

pub const Task = struct {
    task_id: u64,
    task_name: []u8,

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

pub const TaskList = struct {
    list_name: []u8,
    tasks: std.ArrayListUnmanaged(Task) = .empty,
    id: u64 = 0,
    num_tasks: u64 = 0,
    allocator: std.mem.Allocator,

    // functions
    pub fn initTask(list_name: []u8, allocator: std.mem.Allocator) TaskList {
        return TaskList{ .list_name = list_name, .allocator = allocator };
    }

    pub fn deinit(self: *TaskList) void {
        // 1. Free the duplicated string for this specific list name
        self.allocator.free(self.list_name);

        // 2. Loop through and free the string slices inside your tasks
        for (self.tasks.items) |item| {
            self.allocator.free(item.task_name);
        }

        // 3. Clear the array capacity tracking the tasks
        self.tasks.deinit(self.allocator);
    }

    pub fn getTaskListName(self: TaskList) []const u8 {
        return self.list_name;
    }

    // move the tui logic to here?
    pub fn addTask(self: *TaskList, task_name: []u8) !void {
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
        for (self.tasks.items, 0..) |t, i| {
            if (t.getTaskId() == id) {
                self.allocator.free(t.task_name);
                _ = self.tasks.orderedRemove(i);
                return;
            }
        }
    }
};

pub const TodoApplication = struct {
    task_lists: std.ArrayListUnmanaged(TaskList) = .empty,
    allocator: std.mem.Allocator,
    current_list: u64 = 0,
    io: std.Io,

    pub fn initApp(allocator: std.mem.Allocator, io: std.Io) TodoApplication {
        return TodoApplication{ .allocator = allocator, .io = io };
    }

    pub fn deinit(self: *TodoApplication) void {
        for (self.task_lists.items) |*i| {
            i.deinit();
        }

        self.task_lists.deinit(self.allocator);
    }

    pub fn createTodoList(self: *TodoApplication, list_name: []u8) !void {
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

    pub fn addTask(self: *TodoApplication, task_name: []u8) !void {
        try self.task_lists.items[self.current_list].addTask(task_name);
    }

    pub fn removeTask(self: *TodoApplication, task_id: u64) !void {
        self.task_lists.items[self.current_list].removeTaskById(task_id);
    }

    pub fn checkName(self: TodoApplication, list_name: []const u8) bool {
        for (self.task_lists.items) |i| {
            if (std.mem.eql(u8, i.getTaskListName(), list_name)) {
                return true;
            }
        }
        return false;
    }

    //* persistent sotrage (WIP)

    pub fn saveToFile(self: *TodoApplication) !void {
        const file = try std.Io.Dir.cwd().createFile(self.io, SAVE_FILE, .{});
        defer file.close();

        // 2. Instantiate a modern writer wrapper targeting the file
        // We wrap it via a fixed/buffered pipeline depending on your architecture
        var save_buf: [1024]u8 = undefined;
        var buffered_writer = file.writer(self.io, &save_buf);

        // 3. Serialize directly using the new 0.16.0 high-level API
        // Format: value(value_to_serialize, options_struct, writer_pointer)
        try std.json.Stringify.value(&self.task_lists.items, .{ .whitespace = .indent_4 }, // Cleanly formats your JSON output file
            &buffered_writer);
    }

    //pub fn loadFromFile(self: *TodoApplication) !void {}
};
