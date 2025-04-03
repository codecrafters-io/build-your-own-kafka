const std = @import("std");
const net = std.net;
const posix = std.posix;

pub fn main() !void {
    const sock_fd = try posix.socket(posix.AF.INET, posix.SOCK.STREAM, 0);
    defer posix.close(sock_fd);

    const addr = net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, 9092);
    try posix.bind(sock_fd, &addr.any, addr.getOsSockLen());
    try posix.listen(sock_fd, 1);

    // You can use print statements as follows for debugging, they'll be visible when running tests.
    std.debug.print("Logs from your program will appear here!\n", .{});

    // Uncomment this block to pass the first stage
    //
    // var client_addr: posix.sockaddr = undefined;
    // var client_addr_len: posix.socklen_t = @sizeOf(posix.sockaddr);
    // _ = try posix.accept(sock_fd, &client_addr, &client_addr_len, posix.SOCK.CLOEXEC);
}
