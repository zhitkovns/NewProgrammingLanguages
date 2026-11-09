const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const address = try net.IpAddress.parseIp4("127.0.0.1", 8082);
    var server = try address.listen(io, .{ .mode = .stream, .protocol = .tcp, .reuse_address = true });
    defer server.deinit(io);

    std.debug.print("Matrix TCP server listening on 127.0.0.1:8082\n", .{});

    var conn = try server.accept(io);
    defer conn.close(io);

    std.debug.print("Client connected\n", .{});

    var read_buf: [4096]u8 = undefined;
    var reader = conn.reader(io, &read_buf);

    var n_buf: [4]u8 = undefined;
    try reader.interface.readSliceAll(&n_buf);
    const n = std.mem.readInt(u32, &n_buf, .little);
    std.debug.print("Matrix size: {d}x{d}\n", .{ n, n });

    const total_elems = n * n;
    const bytes_len = total_elems * 4;

    var a_buf = try std.heap.page_allocator.alloc(u8, bytes_len);
    defer std.heap.page_allocator.free(a_buf);

    var b_buf = try std.heap.page_allocator.alloc(u8, bytes_len);
    defer std.heap.page_allocator.free(b_buf);

    try reader.interface.readSliceAll(a_buf);
    try reader.interface.readSliceAll(b_buf);

    var res_buf = try std.heap.page_allocator.alloc(u8, bytes_len);
    defer std.heap.page_allocator.free(res_buf);

    var i: usize = 0;
    while (i < total_elems) : (i += 1) {
        const a = std.mem.readInt(i32, a_buf[i * 4 ..][0..4], .little);
        const b = std.mem.readInt(i32, b_buf[i * 4 ..][0..4], .little);
        std.mem.writeInt(i32, res_buf[i * 4 ..][0..4], a + b, .little);
    }

    var write_buf: [4096]u8 = undefined;
    var writer = conn.writer(io, &write_buf);
    try writer.interface.writeAll(res_buf);
    try writer.interface.flush();

    std.debug.print("Result sent, server stopping\n", .{});
}