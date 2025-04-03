The entry point for your Kafka implementation is in `src/main.zig`.

Study and uncomment the relevant code: 

```zig
// Uncomment this block to pass the first stage

var client_addr: posix.sockaddr = undefined;
var client_addr_len: posix.socklen_t = @sizeOf(posix.sockaddr);
_ = try posix.accept(sock_fd, &client_addr, &client_addr_len, posix.SOCK.CLOEXEC);
```

Push your changes to pass the first stage:

```
git add .
git commit -m "pass 1st stage" # any msg
git push origin master
```
