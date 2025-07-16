In this stage, you'll replace the hard-coded correlation ID with the actual correlation ID from the request.

### Request message

A request message has three parts:
1. `message_size`
2. Header
3. Body

To get the `correlation_id` field, you need to find its offset. You already know that `message_size` is 4 bytes long. And here's what the request header looks like (in this stage, we're using [request header v2](https://kafka.apache.org/protocol.html#protocol_messages)):

| Field                 | Data type         | Description                            |
| --------------------- | ----------------- | -------------------------------------- |
| `request_api_key`     | `INT16`           | The API key for the request            |
| `request_api_version` | `INT16`           | The version of the API for the request |
| `correlation_id`      | `INT32`           | A unique identifier for the request    |
| `client_id`           | `NULLABLE_STRING` | The client ID for the request          |
| `TAG_BUFFER`          | `COMPACT_ARRAY`   | Optional tagged fields                 |

To learn more about the different data types, see [Protocol Primitive Types](https://kafka.apache.org/protocol.html#protocol_types).

#### Example

Here's an example of a request message:
```java
00 00 00 23  // message_size:        35
00 12        // request_api_key:     18
00 04        // request_api_version: 4
6f 7f c6 61  // correlation_id:      1870644833
...
```

### Tests

The tester will execute your program like this:
```
$ ./your_program.sh
```

It'll then connect to your broker on port 9092 and send a request with a request header v2:
```
$ echo -n "00000023001200046f7fc66100096b61666b612d636c69000a6b61666b612d636c6904302e3100" | xxd -r -p | nc localhost 9092 | hexdump -C
```

Your broker must send a response with the correct correlation ID:
```java
00 00 00 00  // message_size:   0 (any value works)
6f 7f c6 61  // correlation_id: 1870644833
```

### Notes

- For this stage, you don't need to worry about what the request is asking for. You'll handle that in the next stage.
- For this stage, the tester will only assert that your `message_size` field is 4 bytes long—it won't check the value. You'll implement correct `message_size` values in a later stage.
- The request header version and response header version are unrelated to each other and do not have to match.