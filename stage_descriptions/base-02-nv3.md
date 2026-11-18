Your broker can accept a connection. Clients use a correlation ID to associate a
response with its request. In this stage, you'll send your first binary response
with a fixed correlation ID of `7`.

### The Kafka wire protocol

Kafka brokers communicate with clients through the
[Kafka wire protocol](https://kafka.apache.org/42/design/protocol/). The
protocol uses a request-response model: the client sends a request message, and
the broker replies with a response message.

A Kafka message consists of three parts:

1. `message_size`
2. Header
3. Body

For this stage, you can ignore the body and just focus on `message_size` and the
header. You'll learn about response bodies in later stages.

### The `message_size` field

The
[`message_size`](https://kafka.apache.org/42/design/protocol/#common-request-and-response-structure)
field is a 32-bit signed integer that specifies the size of the header and body
in bytes.

The fixed-width integers used here are in
[big-endian](https://developer.mozilla.org/en-US/docs/Glossary/Endianness) byte
order, with the most significant byte first. A 32-bit integer occupies four
bytes. The examples show each byte as two hexadecimal digits. For example, a
`message_size` of `2` looks like this:

```
00 00 00 02  // message_size: 2
```

For this stage, you only need to ensure that your `message_size` field is 4
bytes long. You'll implement the correct `message_size` values in later stages.

### Response header v0

Kafka has multiple header versions. In this stage, you will use
[response header v0](https://kafka.apache.org/42/design/protocol/#the-messages),
which is the simplest version.

Response header v0 contains a single field:
[`correlation_id`](https://developer.confluent.io/patterns/event/correlation-identifier/).
This field lets clients match responses to their original requests.

The `correlation_id` field is also a 32-bit signed integer. For this stage, your
program must respond with a hard-coded `correlation_id` of `7`.

Your complete response is eight bytes: four for `message_size` and four for
`correlation_id`. Send these binary bytes over the TCP connection. The
hexadecimal text and `//` annotations below describe the bytes and are not part
of the response.

```
00 00 00 00  // message_size:   0 (any value works for this stage)
00 00 00 07  // correlation_id: 7
```

### Tests

The tester will execute your program like this:

```
$ ./your_program.sh /tmp/server.properties
```

It will then connect to your broker on port `9092` and send a Kafka request. You
can also try this local probe:

```
$ echo -n "Placeholder request" | nc -v localhost 9092 | hexdump -C
```

The placeholder command is a local probe. The tester sends a Kafka request,
whose contents you can ignore at this point.

The tester will verify that:

- Your response is 8 bytes total (4 for `message_size`, 4 for `correlation_id`).
- The `correlation_id` field contains the value `7`.

### Notes

- For this stage, you don't need to parse the request. You'll learn about
  request parsing in later stages.
- Fixed-width integers are in
  [big-endian](https://developer.mozilla.org/en-US/docs/Glossary/Endianness)
  order. Kafka also has variable-length encodings, introduced when needed.
