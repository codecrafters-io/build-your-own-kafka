Clients use `ApiVersions` to discover the operations your broker supports. In
this stage, you'll complete the v4 response and replace the placeholder
`message_size` with the actual response length.

### The `ApiVersions` API

The
[`ApiVersions`](https://kafka.apache.org/42/design/protocol/#The_Messages_ApiVersions)
API returns the broker's supported API versions. The response includes a list of
APIs, along with their minimum and maximum supported versions.

We've created an interactive protocol inspector to help you visualize the
request and response structures:

- [ApiVersions Request (v4)](https://binspec.org/kafka-api-versions-request-v4)
- [ApiVersions Response (v4)](https://binspec.org/kafka-api-versions-Response-v4)

### The `ApiVersions` response body

The `ApiVersions` response body (v4) has the following structure:

| Field              | Data type       | Description                                 |
| ------------------ | --------------- | ------------------------------------------- |
| `error_code`       | `INT16`         | Error code (`0` for successful requests)    |
| `api_keys`         | `COMPACT_ARRAY` | Array of supported APIs with version ranges |
| `throttle_time_ms` | `INT32`         | Throttle time in milliseconds               |
| `TAG_BUFFER`       | `TAGGED_FIELDS` | Optional tagged fields                      |

Each entry in the `api_keys` array contains:

| Field         | Data type       | Description               |
| ------------- | --------------- | ------------------------- |
| `api_key`     | `INT16`         | The API identifier        |
| `min_version` | `INT16`         | Minimum supported version |
| `max_version` | `INT16`         | Maximum supported version |
| `TAG_BUFFER`  | `TAGGED_FIELDS` | Optional tagged fields    |

A `COMPACT_ARRAY` starts with its element count plus one, encoded as an unsigned
variable-length integer. Each byte carries seven value bits, least significant
group first. The high bit is set when another byte follows. For example, one
entry starts with `02`, and an empty array starts with `01`.

A `TAG_BUFFER` holds optional extension fields. Its first unsigned
variable-length integer counts the tags, so an empty buffer is `00`. Include the
empty buffer at each position shown in the schema. `ApiVersions` still uses
response header v0, which has no tag buffer.

For this stage, your response must include at least one entry for API key `18`
(ApiVersions) with a `min_version` of `0` and `max_version` of `4`.

Here's an example of what your response might look like:

```java
00 00 00 13  // message_size:      19 bytes
ab cd ef 12  // correlation_id:    (matches request)
00 00        // error_code:        0 (no error)
02           // api_keys array length:    1 element
00 12        // api_key:           18 (ApiVersions)
00 00        // min_version:       0
00 04        // max_version:       4
00           // TAG_BUFFER:        empty
00 00 00 00  // throttle_time_ms:  0
00           // TAG_BUFFER:        empty
```

The tester now validates the `message_size` field. For example, if your response
header is 4 bytes and your body is 15 bytes, your `message_size` should be `19`.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It will then connect to your server on port `9092` and send a valid
`ApiVersions` (v4) request:

```
$ echo -n "000000230012000467890abc00096b61666b612d636c69000a6b61666b612d636c6904302e3100" | xxd -r -p | nc localhost 9092 | hexdump -C
```

Here's what the request looks like:

```java
00 00 00 23  // message_size:        35
00 12        // request_api_key:     18 (ApiVersions)
00 04        // request_api_version: 4
67 89 0a bc  // correlation_id:      1737034428
...          // rest of header and body
```

The tester will validate your response by checking that:

- The `message_size` field correctly represents the size of the header and body.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The `error_code` in the response body is `0`.
- The response includes an entry for API key `18` (ApiVersions), where the
  `min_version` is `0` and the `max_version` is `4`.
- No extra bytes remain after decoding all response fields.

### Notes

- The tester will always send you v4 of the `ApiVersions` request.
- From this stage onwards, the tester will start validating the first 4 bytes of
  your response (the `message_size`) in addition to the other checks.
