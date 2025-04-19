import net from "net";

const server: net.Server = net.createServer((connection: net.Socket) => {
  // Handle connection
});

server.listen(9092, "127.0.0.1");
