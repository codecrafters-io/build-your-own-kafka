import net from "net";

const server = net.createServer((connection) => {
  // Handle connection
});

server.listen(9092, "127.0.0.1");
