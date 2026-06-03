const std = @import("std");
const Io = std.Io;

const structs = @import("structs");

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const allocator = init.gpa;

    var b: std.ArrayList(u8) = .empty;
    try b.append(allocator, 'a');

    defer b.deinit(allocator); // prevents memory leak

    const b_zero: u8 = b.items[0];

    std.debug.print("{c}\n", .{b_zero});
}
