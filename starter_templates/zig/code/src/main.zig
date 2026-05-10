const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // You can use print statements as follows for debugging, they'll be visible when running tests.
    try std.Io.File.writeStreamingAll(std.Io.File.stderr(), io, "Logs from your program will appear here!\n");

    // TODO: Uncomment the code below to pass the first stage
    // const address = try net.IpAddress.parse("127.0.0.1", 9092);
    // var listener = try address.listen(io, .{
    //     .reuse_address = true,
    // });
    // defer listener.deinit(io);
    //
    // _ = try listener.accept(io);
}
