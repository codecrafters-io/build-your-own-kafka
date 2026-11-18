The Listing Partitions extension lets clients discover how a topic's events are
divided into partitions. In this stage, you'll advertise
`DescribeTopicPartitions` in your existing `ApiVersions` response.

### The `ApiVersions` API

The
[`ApiVersions`](https://kafka.apache.org/42/design/protocol/#The_Messages_ApiVersions)
API returns the broker's supported API versions. The
[response](https://binspec.org/kafka-api-versions-Response-v4) includes a list
of APIs, along with their minimum and maximum supported versions.

Keep the `ApiVersions` entry and any entries added by other extensions. Add
`DescribeTopicPartitions` to that list.

### The `DescribeTopicPartitions` API

The
[`DescribeTopicPartitions`](https://kafka.apache.org/42/design/protocol/#The_Messages_DescribeTopicPartitions)
API returns metadata about
[topics](https://kafka.apache.org/42/getting-started/introduction/#main-concepts-and-terminologys:~:text=topics)
and their
[partitions](https://kafka.apache.org/42/getting-started/introduction/#main-concepts-and-terminologys:~:text=partitioned).
A topic is a named event stream, and each partition is an ordered log within it.
Clients need metadata such as partition IDs to address the right log. This stage
only advertises the API's availability.

Your `ApiVersions` response should now include these two required entries in the
`api_keys` array, alongside any other supported APIs:

- `ApiVersions` (API key `18`): `min_version` `0`, `max_version` `4`.
- `DescribeTopicPartitions` (API key `75`): `min_version` `0`, `max_version`
  `0`.

Here's an example containing only those two entries:

```bash
00 00 00 1a  // message_size:      26 bytes
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

It will then connect to your server on port `9092` and send a valid
`ApiVersions` (v4) request:

```
$ echo -n "000000230012000467890abc00096b61666b612d636c69000a6b61666b612d636c6904302e3100" | xxd -r -p | nc localhost 9092 | hexdump -C
```

The tester will validate that:

- The `message_size` field correctly represents the size of the header and body.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The `error_code` in the response body is `0` (No Error).
- The response body includes entries for both API key 18 (`ApiVersions`) and API
  key 75 (`DescribeTopicPartitions`).
- The API key `18` (`ApiVersions`) response has a `min_version` of `0` and a
  `max_version` of at least `4`.
- The API key `75` (`DescribeTopicPartitions`) response has a `min_version` of
  `0` and a `max_version` of at least `0`.

### Notes

- You'll still need to include the entry for `ApiVersions` in your response to
  pass the previous stages.
- We'll get to implementing the `DescribeTopicPartitions` request in later
  stages. For this stage, you only need to add an entry to the ApiVersions
  response.
