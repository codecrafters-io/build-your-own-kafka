const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const address = try net.IpAddress.parse("127.0.0.1", 9092);
    var listener = try address.listen(io, .{
        .reuse_address = true,
    });
    defer listener.deinit(io);

    _ = try listener.accept(io);
}
