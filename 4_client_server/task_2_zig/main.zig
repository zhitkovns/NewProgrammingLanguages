const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var stream: ?net.Stream = null;
    var attempts: u32 = 0;

    while (attempts < 3) : (attempts += 1) {
        std.debug.print("attempt {d} of 3\n", .{attempts + 1});

        const address = try net.IpAddress.parseIp4("127.0.0.1", 8080);
        stream = address.connect(io, .{ .mode = .stream, .protocol = .tcp }) catch |err| {
            std.debug.print("connect error: {s}\n", .{@errorName(err)});
            io.sleep(.fromMilliseconds(500), .awake) catch {};
            continue;
        };
        break;
    }

    if (stream == null) {
        std.debug.print("failed to connect after 3 attempts\n", .{});
        return error.ConnectFailed;
    }

    const conn = stream.?;
    defer conn.close(io);

    std.debug.print("connected\n", .{});

    const message = "Hello from Zig client\n";

    var write_buf: [1024]u8 = undefined;
    var writer = conn.writer(io, &write_buf);
    try writer.interface.writeAll(message);
    try writer.interface.flush();
    std.debug.print("sent: Hello from Zig client\n", .{});

    var read_buf: [1024]u8 = undefined;
    var reader = conn.reader(io, &read_buf);

    const maybe_line = reader.interface.takeDelimiter('\n') catch |err| {
        std.debug.print("read error: {s}\n", .{@errorName(err)});
        return err;
    };

    if (maybe_line) |line| {
        std.debug.print("received: {s}\n", .{line});
    } else {
        std.debug.print("connection closed by peer before newline\n", .{});
    }
}