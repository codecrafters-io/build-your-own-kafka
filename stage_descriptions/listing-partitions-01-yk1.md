In this stage, you'll add an entry for the `DescribeTopicPartitions` API to the `ApiVersions` response.

### The `ApiVersions` API (Recap)

As a recap, the [`ApiVersions`](https://kafka.apache.org/protocol.html#The_Messages_ApiVersions) API returns the broker's supported API versions. The [response](https://binspec.org/kafka-api-versions-Response-v4) includes a list of APIs, along with their minimum and maximum supported versions.

In previous stages, you implemented the `ApiVersions` response with a single entry for the `ApiVersions` API itself. Now you'll add a second entry for the `DescribeTopicPartitions` API.

### The `DescribeTopicPartitions` API

The [`DescribeTopicPartitions`](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions) API returns metadata about [topics](https://kafka.apache.org/documentation/#intro_concepts_and_terms) and their [partitions](https://kafka.apache.org/documentation/#:~:text=partitioned). For this stage, you only need to advertise support for it in the `ApiVersions` response. You'll implement the actual API handling in later stages.

Your `ApiVersions` response should now include two entries in the `api_keys` array:

- `ApiVersions` (API key `18`): `min_version` `0`, `max_version` `4`.
- `DescribeTopicPartitions` (API key `75`): `min_version` `0`, `max_version` `0`.

Here's an example of what your updated response might look like:

```bash
00 00 00 1d  // message_size:      29 bytes
ab cd ef 12  // correlation_id:    (matches request)
00 00        // error_code:        0 (no error)
03           // api_keys array:    2 elements (compact array encoding)
00 12        // api_key:           18 (ApiVersions)
00 00        // min_version:       0
00 04        // max_version:       4
00           // TAG_BUFFER:        empty
00 4b        // api_key:           75 (DescribeTopicPartitions)
00 00        // min_version:       0
00 00        // max_version:       0
00           // TAG_BUFFER:        empty
00 00 00 00  // throttle_time_ms:  0
00           // TAG_BUFFER:        empty
```

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It will then connect to your server on port `9092` and send a valid `ApiVersions` (v4) request:

```
$ echo -n "0000001a0012000467890abc00096b61666b612d636c69000a6b61666b612d636c6904302e3100" | xxd -r -p | nc localhost 9092 | hexdump -C
```

The tester will validate that:

- The `message_size` field correctly represents the size of the header and body.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `error_code` in the response body is `0` (No Error).
- The response body includes entries for both API key 18 (`ApiVersions`) and API key 75 (`DescribeTopicPartitions`).
- The API key `18` (`ApiVersions`) response has a `min_version` of `0` and a `max_version` of at least `4`.
- The API key `75` (`DescribeTopicPartitions`) response has a `min_version` of `0` and a `max_version` of at least `0`.

### Notes

- You'll still need to include the entry for `ApiVersions` in your response to pass the previous stages.
- We'll get to implementing the `DescribeTopicPartitions` request in later stages. For this stage, you only need to add an entry to the ApiVersions response.
