const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const address = try net.IpAddress.parseIp4("127.0.0.1", 8082);
    var stream = try address.connect(io, .{ .mode = .stream, .protocol = .tcp });
    defer stream.close(io);

    var write_buf: [1024]u8 = undefined;
    var writer = stream.writer(io, &write_buf);

    const n: u32 = 2;
    try writer.interface.writeAll(std.mem.asBytes(&n));
    
    const a = [_]i32{ 1, 2, 3, 4 };
    const b = [_]i32{ 5, 6, 7, 8 };
    
    try writer.interface.writeAll(std.mem.sliceAsBytes(a[0..]));
    try writer.interface.writeAll(std.mem.sliceAsBytes(b[0..]));
    try writer.interface.flush();

    var read_buf: [1024]u8 = undefined;
    var reader = stream.reader(io, &read_buf);
    
    var res_bytes: [16]u8 = undefined;
    try reader.interface.readSliceAll(&res_bytes);
    
    var result: [4]i32 = undefined;
    @memcpy(std.mem.sliceAsBytes(result[0..]), &res_bytes);
    
    std.debug.print("Result matrix: {any}\n", .{result});
}