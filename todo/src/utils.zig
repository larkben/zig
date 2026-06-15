const std = @import("std");

const init = std.process.Init;
const io = init.io;

// write out
pub fn print(out_buf: [1024]u8, content: []const u8) void {
    // create raw buffer (write) -> stored on the stack
    // * from an effciency standpoint it would be better to probably to use a shared buffer
    var stdout_writer = std.Io.File.stdout().writer(io, &out_buf);
    const stdout = &stdout_writer.interface;

    try stdout.writeAll(content);
    try stdout.flush(); // might not even need to since the stdout is dropped once it goes outta scope
}

// write in
pub fn input(in_buf: [1024]u8) []const u8 {
    // setup stdin buffer and reader interface (read) -> stored on the stack
    var stdin_reader = std.Io.File.stdin().reader(io, &in_buf);
    const stdin = &stdin_reader.interface;

    const content = try stdin.takeDelimiterExclusive('\n');
    return content;
}
