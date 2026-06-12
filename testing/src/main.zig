const std = @import("std");
const Io = std.Io;

const Tree = struct {
    name: []const u8,

    pub fn initTree(name: []const u8) Tree {
        return Tree{ .name = name };
    }

    pub fn changeName(self: *Tree) void {
        self.name = "cherry";
        std.debug.print("The new name is now: {s}\n", .{self.name});
    }
};

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    const allocator = init.gpa;
    var list: std.ArrayList(u8) = .empty;

    defer list.deinit(allocator);

    try list.append(allocator, 'a');

    std.debug.print("{c}\n", .{list.items[0]});

    testPointer();

    var a: Tree = Tree.initTree("apple");
    a.changeName();
}

fn testPointer() void {
    const x: i32 = 1234;
    const x_ptr = &x;
    std.debug.print("{d}\n", .{x_ptr.*}); // dereference
}
