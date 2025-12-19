In this stage, you'll replace the hardcoded correlation ID with the actual correlation ID from the request.

### Kafka Message Structure

As a recap, Kafka request and response messages have the following format:

1. `message_size`: The size of the header and body
2. Header: Contains metadata about the request
3. Body: Contains the actual request data

In a previous stage, you sent a response with a hardcoded `correlation_id`. Now you'll extract the actual `correlation_id` from the incoming request header and echo it back.

### Parsing the Request Header

To extract the `correlation_id`, you need to parse the request header. For this stage, you'll work with [request header v2](https://kafka.apache.org/protocol.html#protocol_messages).

Here’s what the structure looks like:

| Field                 | Data type         | Size (bytes) | Description                            |
| --------------------- | ----------------- | ------------ | -------------------------------------- |
| `request_api_key`     | `INT16`           | 2            | The API key for the request            |
| `request_api_version` | `INT16`           | 2            | The version of the API for the request |
| `correlation_id`      | `INT32`           | 4            | A unique identifier for the request    |
| `client_id`           | `NULLABLE_STRING` | Variable     | The client ID for the request          |
| `TAG_BUFFER`          | `TAGGED_FIELDS`   | Variable     | Optional tagged fields                 |

_To learn more about the different data types, see [Protocol Primitive Types](https://kafka.apache.org/protocol.html#protocol_types)._

To get the `correlation_id` field, you need to find its offset in the request message. Here's an example request showing where each field is located:

```java
00 00 00 23  // message_size:        35
00 12        // request_api_key:     18
00 04        // request_api_version: 4
6f 7f c6 61  // correlation_id:      1870644833
...
```

Your response will use the same structure from the previous stage:

```
00 00 00 00  // message_size:   0 (any value works for this stage)
6f 7f c6 61  // correlation_id: 1870644833 (extracted from request)
```

### Tests

The tester will execute your program like this:

```
$ ./your_program.sh
```

It will then connect to your broker on port `9092` and send a request with a request header v2:

```
$ echo -n "00000023001200046f7fc66100096b61666b612d636c69000a6b61666b612d636c6904302e3100" | xxd -r -p | nc localhost 9092 | hexdump -C
```

Your broker must extract the correlation ID from the request and echo it back:

```
00 00 00 00  // message_size:   0 (any value works for this stage)
6f 7f c6 61  // correlation_id: 1870644833
```

### Notes

- For this stage, you don't need to worry about what the request is asking for. You'll handle that at a later stage.
- For this stage, the tester will only assert that your `message_size` field is 4 bytes long—it won't check the value. You'll implement correct `message_size` values in a later stage.
- The request header version and response header version are unrelated to each other and do not have to match.
