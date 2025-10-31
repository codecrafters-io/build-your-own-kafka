In this stage, you'll parse the `request_api_version` field in the request header and respond with an error code if the version is invalid.

### Kafka APIs

Every Kafka request is an API call. The Kafka protocol defines over 70 different APIs, each serving a different purpose. Here are some examples:
- `Produce`: Writes events to partitions.
- `CreateTopics`: Creates new topics.
- `ApiVersions`: Returns the broker's supported API versions.

A Kafka request specifies the API it's calling using the [`request_api_key`](https://kafka.apache.org/protocol.html#protocol_api_keys) header field.

### Message Body

As a recap, Kafka requests and responses have the following format:

1. `message_size`
2. Header
3. Body

So far, you've only worked with `message_size` and the header. Now you'll start working with the message body.

Each API defines the schemas for its request and response bodies. 

For example, the [`Produce API`](https://kafka.apache.org/protocol.html#The_Messages_Produce) request body contains fields like:

- The name of the topic to write to.
- The key of the partition to write to.
- The event data to write.

The `Produce` response body contains response codes indicating whether each write succeeded.

### API Versioning

Each API supports multiple versions to allow schemas to evolve over time. Here's how API versioning works:

- Requests use the `request_api_version` header field to specify which version they're using.
- Responses use the same version as the request when that version is supported. For example, a `Produce Request (Version: 3)` should receive a `Produce Response (Version: 3)` back.
- Each API's version history is independent. `Produce (Version: 10)` is unrelated to `Fetch (Version: 10)`.

### The `ApiVersions` API

The [`ApiVersions`](https://kafka.apache.org/protocol.html#The_Messages_ApiVersions) API returns the broker's supported API versions. For example, it might indicate that the broker supports `Produce` versions `5-11`, `Fetch` versions `0-3`, and so on.

In this stage, you'll begin adding support for `ApiVersions` version 4. For now, you only need to add support for the `error_code` field. You'll implement the other fields in later stages.

### The `error_code` Field

The `ApiVersions` response body begins with a 16-bit signed integer called the `error_code`. This field indicates if an error occurred with the request. It's set to `0` if there was no error. For all possible error codes, see the [error codes chart](https://kafka.apache.org/protocol.html#protocol_error_codes).

For this stage, you only need to handle error code `35` (`UNSUPPORTED_VERSION`). This error occurs when the client requests a version of `ApiVersions` that the broker doesn't support. You can assume your broker supports versions `0-4`.

### Tests

The tester will execute your program like this:

```
$ ./your_program.sh
```

It will then connect to your broker on port `9092` and send an `ApiVersions` request with an unsupported version:

```
$ echo -n "000000230012674a4f74d28b00096b61666b612d636c69000a6b61666b612d636c6904302e3100" | xxd -r -p | nc localhost 9092 | hexdump -C
```

Here's what the request looks like:

```java
00 00 00 23  // message_size:        35
00 12        // request_api_key:     18
67 4a        // request_api_version: 26442
4f 74 d2 8b  // correlation_id:      1333056139
...
```

Your broker must respond with an `ApiVersions` version 4 response containing the `error_code` field set to `35`:
```java
00 00 00 00  // message_size:   0 (any value works)
4f 74 d2 8b  // correlation_id: 1333056139
00 23        // error_code:     35
```

When the request has a valid version (`0-4`), your broker should respond with error code `0`, though this isn't tested in this stage.

### Notes

- The Kafka protocol's APIs are different from Kafka's [core APIs](https://kafka.apache.org/documentation/#intro_apis). The core APIs are higher-level Java and Scala APIs that wrap around the Kafka protocol.
- You can assume that the tester will only send you an `ApiVersions` request. You don't need to check the `request_api_key` field in the header.
- For this stage, the tester will only assert that your `message_size` field is 4 bytes long—it won't check the value. You'll implement correct `message_size` values in a later stage.
