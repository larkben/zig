const std = @import("std");
const Io = std.Io;
const c = @import("c");

pub fn main() !void {
    var db: ?*c.sqlite3 = null;

    if (c.sqlite3_open("shop.db", &db) != c.SQLITE_OK) {
        std.debug.print("Failed to open database\n", .{});
        return;
    }

    defer _ = c.sqlite3_close(db);

    std.debug.print("Database opened successfully!\n", .{});
}

const Shop = struct {
    // data
};

const Category = enum {
    // types
    shirt,
    sweathshirt,
    hat,
    transfer,
};
