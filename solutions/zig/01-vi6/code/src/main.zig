const std = @import("std");
const net = std.net;
const posix = std.posix;

pub fn main() !void {
    const address = try net.Address.resolveIp("127.0.0.1", 9092);
    var listener = try address.listen(.{
        .reuse_address = true,
    });
    defer listener.deinit();

    _ = try listener.accept();
}
