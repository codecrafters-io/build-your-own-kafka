The entry point for your Kafka implementation is in `src/main.zig`.

Study and uncomment the relevant code: 

```zig
// Uncomment this block to pass the first stage
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
```

Push your changes to pass the first stage:

```
git add .
git commit -m "pass 1st stage" # any msg
git push origin master
```
