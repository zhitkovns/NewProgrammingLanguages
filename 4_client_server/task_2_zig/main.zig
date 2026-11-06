const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var stream: ?std.net.Stream = null;

    var attempts: u32 = 0;
    while (attempts < 3) : (attempts += 1) {
        std.debug.print("attempt {d} of 3\n", .{attempts + 1});
        stream = std.net.tcpConnectToHost(allocator, "127.0.0.1", 8080) catch |err| {
            std.debug.print("connect error: {s}\n", .{@errorName(err)});
            std.time.sleep(500 * std.time.ns_per_ms);
            continue;
        };
        break;
    }

    if (stream == null) {
        std.debug.print("failed to connect after 3 attempts\n", .{});
        return error.ConnectFailed;
    }

    const conn = stream.?;
    defer conn.close();

    std.debug.print("connected\n", .{});

    const message = "Hello from Zig client";
    _ = conn.write(message) catch |err| {
        std.debug.print("write error: {s}\n", .{@errorName(err)});
        return err;
    };
    std.debug.print("sent: {s}\n", .{message});

    var buffer: [1024]u8 = undefined;
    const n = conn.read(&buffer) catch |err| {
        std.debug.print("read error: {s}\n", .{@errorName(err)});
        return err;
    };

    if (n == 0) {
        std.debug.print("connection closed by peer\n", .{});
        return;
    }
    std.debug.print("received: {s}\n", .{buffer[0..n]});
}