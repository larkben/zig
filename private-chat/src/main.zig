const std = @import("std");
const c = @import("c");

const default_port: u16 = 2222;
const listen_backlog = 16;

pub fn main(init: std.process.Init) !void {
    var args = std.process.Args.Iterator.init(init.minimal.args);
    _ = args.skip();

    const port = if (args.next()) |arg|
        std.fmt.parseInt(u16, arg, 10) catch |err| {
            std.debug.print("invalid port '{s}': {s}\n", .{ arg, @errorName(err) });
            return;
        }
    else
        default_port;

    const server_fd = try openServerSocket(port);
    defer _ = c.close(server_fd);

    std.debug.print("private-chat SSH test server listening on 127.0.0.1:{d}\n", .{port});
    std.debug.print("try: ssh -p {d} localhost\n", .{port});

    while (true) {
        var client_addr: c.struct_sockaddr_in = undefined;
        var client_addr_len: c.socklen_t = @sizeOf(c.struct_sockaddr_in);
        const client_fd = c.accept(
            server_fd,
            @ptrCast(&client_addr),
            &client_addr_len,
        );

        if (client_fd < 0) {
            std.debug.print("accept failed: {s}\n", .{lastErrorMessage()});
            continue;
        }

        handleClient(client_fd) catch |err| {
            std.debug.print("client error: {s}\n", .{@errorName(err)});
        };
    }
}

fn openServerSocket(port: u16) !c_int {
    const fd = c.socket(c.AF_INET, c.SOCK_STREAM, 0);
    if (fd < 0) {
        std.debug.print("socket failed: {s}\n", .{lastErrorMessage()});
        return error.SocketFailed;
    }
    errdefer _ = c.close(fd);

    var reuse: c_int = 1;
    if (c.setsockopt(fd, c.SOL_SOCKET, c.SO_REUSEADDR, &reuse, @sizeOf(c_int)) < 0) {
        std.debug.print("setsockopt failed: {s}\n", .{lastErrorMessage()});
        return error.SetSockOptFailed;
    }

    var addr = std.mem.zeroes(c.struct_sockaddr_in);
    if (@hasField(c.struct_sockaddr_in, "sin_len")) {
        addr.sin_len = @sizeOf(c.struct_sockaddr_in);
    }
    addr.sin_family = c.AF_INET;
    addr.sin_port = c.htons(port);
    addr.sin_addr.s_addr = c.htonl(c.INADDR_LOOPBACK);

    if (c.bind(fd, @ptrCast(&addr), @sizeOf(c.struct_sockaddr_in)) < 0) {
        std.debug.print("bind failed: {s}\n", .{lastErrorMessage()});
        return error.BindFailed;
    }

    if (c.listen(fd, listen_backlog) < 0) {
        std.debug.print("listen failed: {s}\n", .{lastErrorMessage()});
        return error.ListenFailed;
    }

    return fd;
}

fn handleClient(client_fd: c_int) !void {
    defer _ = c.close(client_fd);

    const server_banner = "SSH-2.0-private-chat_0.1\r\n";
    try sendAll(client_fd, server_banner);

    var buffer: [512]u8 = undefined;
    const len = try readLine(client_fd, &buffer);
    const client_banner = std.mem.trimEnd(u8, buffer[0..len], "\r\n");

    std.debug.print("client banner: {s}\n", .{client_banner});

    const message =
        "SSH banner exchange complete. Key exchange/auth/session support is not implemented yet.\r\n";
    try sendAll(client_fd, message);
}

fn readLine(fd: c_int, buffer: []u8) !usize {
    var used: usize = 0;
    while (used < buffer.len) {
        var byte: [1]u8 = undefined;
        const received = c.recv(fd, &byte, byte.len, 0);
        if (received < 0) {
            std.debug.print("recv failed: {s}\n", .{lastErrorMessage()});
            return error.RecvFailed;
        }
        if (received == 0) {
            return used;
        }

        buffer[used] = byte[0];
        used += 1;

        if (byte[0] == '\n') {
            return used;
        }
    }

    return used;
}

fn sendAll(fd: c_int, bytes: []const u8) !void {
    var sent: usize = 0;
    while (sent < bytes.len) {
        const written = c.send(fd, bytes.ptr + sent, bytes.len - sent, 0);
        if (written < 0) {
            std.debug.print("send failed: {s}\n", .{lastErrorMessage()});
            return error.SendFailed;
        }
        if (written == 0) {
            return error.ConnectionClosed;
        }
        sent += @intCast(written);
    }
}

fn errno() c_int {
    return std.c._errno().*;
}

fn lastErrorMessage() [:0]const u8 {
    return std.mem.span(c.strerror(errno()));
}
