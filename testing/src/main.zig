const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    const allocator = init.gpa;
    var list: std.ArrayList(u8) = .empty;

    defer list.deinit(allocator);

    try list.append(allocator, 'a');

    std.debug.print("{c}\n", .{list.items[0]});
}
