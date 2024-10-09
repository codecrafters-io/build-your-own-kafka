const std = @import("std");
const net = std.net;

pub fn main() !void {
    const address = try net.Address.resolveIp("127.0.0.1", 9092);

    var listener = try address.listen(.{
       .reuse_address = true,
    });
    defer listener.deinit();

    while (true) {
       const connection = try listener.accept();
       std.debug.print("accepted new connection\n", .{});
       connection.stream.close();
    }
}
