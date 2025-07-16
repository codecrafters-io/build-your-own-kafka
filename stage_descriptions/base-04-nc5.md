In this stage, you'll parse the `request_api_version` field in the request header and respond with an error code if the version is invalid.

### Kafka APIs

Every Kafka request is an API call. The Kafka protocol defines over 70 different APIs, all of which do different things. Here are some examples:
- `Produce` writes events to partitions.
- `CreateTopics` creates new topics.
- `ApiVersions` returns the broker's supported API versions.

A Kafka request specifies the API its calling by using the [`request_api_key`](https://kafka.apache.org/protocol.html#protocol_api_keys) header field.

### Message body

The schemas for the request and response bodies are determined by the API being called.

For example, here are some of the fields that the [`Produce`](https://kafka.apache.org/protocol.html#The_Messages_Produce) request body contains:

- The name of the topic to write to.
- The key of the partition to write to.
- The event data to write.

On the other hand, the `Produce` response body contains a response code for each event. These response codes indicate if the writes succeeded.

As a reminder, requests and responses both have the following format:

1. `message_size`
2. Header
3. Body

### API versioning

Each API supports multiple versions, to allow for different schemas. Here's how API versioning works:
- Requests use the header field `request_api_version` to specify the API version being requested.
- Responses always use the same API version as the request. For example, a `Produce Request (Version: 3)` will always get a `Produce Response (Version: 3)` back.
- Each API's version history is independent. So, different APIs with the same version are unrelated. For example, `Produce Request (Version: 10)` is not related to `Fetch Request (Version: 10)`.

### The `ApiVersions` API

The [`ApiVersions`](https://kafka.apache.org/protocol.html#The_Messages_ApiVersions) API returns the broker's supported API versions. For example, `ApiVersions` may say that the broker supports `Produce` versions 5 to 11, `Fetch` versions 0 to 3, etc.

In this stage, you'll begin to add support for `ApiVersions` version 4. For this stage, you only need to add support for the `error_code` field. You'll implement the other fields in later stages.

Note: As of Oct 30th 2024, [version 4](https://github.com/apache/kafka/blob/84caaa6e9da06435411510a81fa321d4f99c351f/clients/src/main/resources/common/message/ApiVersionsRequest.json#L25C22-L25C33) of `ApiVersions` is still unreleased, so it isn't available in the Kafka docs yet. However, the request and response formats for `ApiVersions` version 4 are identical to those of version 3. The docs for version 4 will be available once Kafka 3.9 is released.

The `ApiVersions` response body begins with `error_code`, a 16-bit signed integer. This field indicates if an error occurred with the request. It's set to 0 if there was no error. To see all the possible values, consult the [error codes chart](https://kafka.apache.org/protocol.html#protocol_error_codes).

You only need to add support for error code 35, `UNSUPPORTED_VERSION`. This error code occurs when the version of `ApiVersions` requested by the client is not supported by the broker. Assume that your broker only supports versions 0 to 4.

### Tests

The tester will execute your program like this:
```
$ ./your_program.sh
```

It'll then connect to your broker on port 9092 and send an `ApiVersions` request. This request will ask for an unsupported version of `ApiVersions`:
```
$ echo -n "000000230012674a4f74d28b00096b61666b612d636c69000a6b61666b612d636c6904302e3100" | xxd -r -p | nc localhost 9092 | hexdump -C
```
```java
00 00 00 23  // message_size:        35
00 12        // request_api_key:     18
67 4a        // request_api_version: 26442
4f 74 d2 8b  // correlation_id:      1333056139
...
```

Your broker should send an `ApiVersions` version 4 response with the `error_code` field set to **35** because of the unsupported version in the request:
```java
00 00 00 00  // message_size:   0 (any value works)
4f 74 d2 8b  // correlation_id: 1333056139
00 23        // error_code:     35
```

You broker should send an `ApiVersions` response with the `error_code` field set to **0** when the request is valid, though we are not testing for that in this stage.

### Notes

- The Kafka protocol's APIs are different from Kafka's [core APIs](https://kafka.apache.org/documentation/#intro_apis). The core APIs are higher-level Java and Scala APIs that wrap around the Kafka protocol.
- You can assume that the tester will only send you an `ApiVersions` request. You don't need to check the `request_api_key` field in the header.
- For this stage, the tester will only assert that your `message_size` field is 4 bytes long—it won't check the value. You'll implement correct `message_size` values in a later stage.