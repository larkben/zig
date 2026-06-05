const std = @import("std");

// zigs networking library for 16.0
const net = std.Io.net;

// https server in zig
pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // parse the localhost IP address and port
    const addr = try net.IpAddress.parse("127.0.0.1", 8080);

    // create the TCP listening server; we pass the IO engine explicitly
    var server = try addr.listen(io, .{});
    defer server.deinit(io);

    while (true) {
        var connection = server.accept(io) catch |err| {
            std.debug.print("failed connection: {}", .{err});
            continue;
        };

        defer connection.close(io);

        // concrete stream reader and writer
        var in_buf: [1024 * 4]u8 = undefined;
        var out_buf: [1024 * 4]u8 = undefined;

        var stream_reader = connection.reader(io, &in_buf);
        var stream_writer = connection.writer(io, &out_buf);

        var http_server = std.http.Server.init(&stream_reader.interface, &stream_writer.interface);

        var request = http_server.receiveHead() catch |err| {
            // content
            std.debug.print("failed to reach http headers: {}", .{err});
            continue;
        };

        const target = request.head.target;
        if (std.mem.eql(u8, target, "/")) {
            try request.respond("Welcome to my Zig Http Server!\n", .{});
        }
    }
}
