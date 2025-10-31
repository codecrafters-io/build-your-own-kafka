In this stage, you'll send a response with a correlation ID.

### The Kafka Wire Protocol

Kafka brokers communicate with clients through the [Kafka wire protocol](https://kafka.apache.org/protocol.html). The protocol uses a request-response model: the client sends a request message, and the broker replies with a response message.

A Kafka request or response message consists of three parts:
1. `message_size`
2. Header
3. Body

For this stage, you can ignore the body and just focus on `message_size` and the header. You'll learn about response bodies in a later stage.

### The `message_size` Field

The [`message_size`](https://kafka.apache.org/protocol.html#protocol_common) field is a 32-bit signed integer that specifies the size of the header and body in bytes.

All integers in the Kafka protocol are in [big-endian](https://developer.mozilla.org/en-US/docs/Glossary/Endianness) byte order. For example, a `message_size` of `2` looks like this:

```
00 00 00 02  // message_size: 2
```

For this stage, you only need to ensure that your `message_size` field is 4 bytes long. You'll implement the correct `message_size` values in a later stage.

### Response Header v0

Kafka has multiple header versions. In this stage, you will use [response header v0](https://kafka.apache.org/protocol.html#protocol_messages), which is the simplest version. 

Response header v0 contains a single field: [`correlation_id`](https://developer.confluent.io/patterns/event/correlation-identifier/). This field lets clients match responses to their original requests.

The `correlation_id` field is also a 32-bit signed integer. For this stage, your program must respond with a hard-coded `correlation_id` of `7`.

Putting it all together, your complete response should be 8 bytes long: 4 bytes for `message_size` and 4 bytes for the header (`correlation_id`).

```
00 00 00 00  // message_size:   0 (any value works for this stage)
00 00 00 07  // correlation_id: 7
```

### Tests

The tester will execute your program like this:
```
$ ./your_program.sh
```

It will then connect to your broker on port `9092` and send a request:
```
$ echo -n "Placeholder request" | nc -v localhost 9092 | hexdump -C
```

Your broker must send a response with this structure:
```
00 00 00 00  // message_size:   0 (any value works for this stage)
00 00 00 07  // correlation_id: 7
```

The tester will verify that:
- Your response is 8 bytes total (4 for `message_size`, 4 for `correlation_id`).
- The `correlation_id` field contains the value `7`.

### Notes

- For this stage, you don't need to parse the request. You'll learn about request parsing in a later stage.
- All integers are in [big-endian](https://developer.mozilla.org/en-US/docs/Glossary/Endianness) order.
