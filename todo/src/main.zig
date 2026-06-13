const std = @import("std");
const todo = @import("todo.zig");

// TODO
// 1. make each task have like details and deadlines and stuff
// 3. overall ui improvements

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

    var app = todo.TodoApplication.initApp(allocator, io);

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

                // append and handle
                if (!app.checkName(entry)) {
                    const saved_entry = try allocator.dupe(u8, entry);

                    try app.createTodoList(saved_entry);

                    // confirmation
                    std.debug.print("\n{s} has been created.\n", .{entry});
                } else {
                    std.debug.print("This name for a list is already taken.\n", .{});
                }
            },
            .toggle => {
                // request task name
                app.printLists();
                try stdout.writeAll("Enter Todo List Name: ");
                try stdout.flush();

                // get task name
                const entry = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);

                //* here we do not need to use a allocator.dupe as we don't later need to display the slice

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

                const saved_entry = try allocator.dupe(u8, entry);

                // append
                try app.addTask(saved_entry);

                // confirmation
                std.debug.print("\nTask Added.\n", .{});
            },
            .remove => {
                // print tasks and then prompt for removal
                app.printCurrentList();
                try stdout.writeAll("Enter Task Id to Remove: ");
                try stdout.flush();

                // get task id
                const entry = try stdin.takeDelimiterExclusive('\n');
                stdin.toss(1);

                const trimmedEntry = std.mem.trimEnd(u8, entry, "\r");

                const intEntry = try std.fmt.parseInt(u64, trimmedEntry, 10);

                // removal
                try app.removeTask(intEntry);

                // confirmation
                std.debug.print("\nTask Removed.\n", .{});
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

    // Save the content on close
    try app.saveToFile();
}

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
