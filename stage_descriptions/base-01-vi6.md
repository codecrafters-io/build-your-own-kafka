In this stage, you'll implement a TCP server that listens on port 9092.

[TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) is the underlying protocol that Kafka brokers and clients use to communicate with each other.

### Tests

The tester will execute your program like this:
```
$ ./your_program.sh
```

It'll then try to connect to your TCP server on port 9092. If the connection succeeds, you'll pass this stage.

### Notes

- If you already have a Kafka broker running on port 9092 and you run your program, you'll get a "port already in use" error. To fix this, terminate the existing Kafka broker and run your program again.
- 9092 is the default port that Kafka uses.