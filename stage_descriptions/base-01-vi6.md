Before a client can read or write events, it needs a connection to your Kafka
broker. In this stage, start a TCP server that listens on port `9092`, Kafka's
default port.

TCP provides an ordered stream of bytes between two programs. A listening socket
waits for clients at an address and port. Keep your program running so the
tester can connect to `localhost:9092` after starting
`./your_program.sh /tmp/server.properties`.

You don't need to read requests or send responses yet. The tester supplies the
configuration file argument, but you can ignore its contents in this stage.
