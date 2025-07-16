In this stage, you'll send a response with a correlation ID.

### Response message

Kafka brokers communicate with clients through the [Kafka wire protocol](https://kafka.apache.org/protocol.html). The protocol uses a request-response model, where the client sends a request message and the broker replies with a response message.

A Kafka response message has three parts:
1. `message_size`
2. Header
3. Body

For this stage, you can ignore the body and just focus on `message_size` and the header. You'll learn about response bodies in a later stage.

#### The `message_size` field

The [`message_size`](https://kafka.apache.org/protocol.html#protocol_common) field is a 32-bit signed integer. It specifies the size of the header and body.

For this stage, the tester will only assert that your `message_size` field is 4 bytes long—it won't check the value. You'll implement correct `message_size` values in a later stage.

#### Header

Kafka has a few different header versions. The way Kafka determines which header version to use is a bit complicated and is outside the scope of this challenge. For more information, take a look at [KIP-482](https://cwiki.apache.org/confluence/display/KAFKA/KIP-482%3A+The+Kafka+Protocol+should+Support+Optional+Tagged+Fields) and this [Stack Overflow answer](https://stackoverflow.com/a/71853003).

In this stage, you will use [response header v0](https://kafka.apache.org/protocol.html#protocol_messages) (scroll down).

Response header v0 contains a single field: [`correlation_id`](https://developer.confluent.io/patterns/event/correlation-identifier/). This field lets clients match responses to their original requests. Here's how it works:

1. The client generates a correlation ID.
2. The client sends a request that includes the correlation ID.
3. The broker sends a response that includes the same correlation ID.
4. The client receives the response and matches the correlation ID to the original request.

The `correlation_id` field is a 32-bit signed integer. For this stage, your program must respond with a hard-coded `correlation_id` of 7.

### Tests

The tester will execute your program like this:
```
$ ./your_program.sh
```

It'll then connect to your broker on port 9092 and send a request:
```
$ echo -n "Placeholder request" | nc -v localhost 9092 | hexdump -C
```

Your broker must send a response with a correlation ID of 7:
```java
00 00 00 00  // message_size:   0 (any value works)
00 00 00 07  // correlation_id: 7
```

### Notes

- For this stage, you don't need to parse the request. You'll learn about request parsing in a later stage.
- All integers are in [big-endian](https://developer.mozilla.org/en-US/docs/Glossary/Endianness) order.