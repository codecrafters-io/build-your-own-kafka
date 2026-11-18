Your broker advertises `DescribeTopicPartitions`. In this stage, you'll answer a
request for a topic that does not exist so the client can distinguish a missing
topic from a successful lookup.

### The `DescribeTopicPartitions` API

The
[`DescribeTopicPartitions`](https://kafka.apache.org/42/design/protocol/#The_Messages_DescribeTopicPartitions)
API returns metadata about
[topics](https://kafka.apache.org/42/getting-started/introduction/#main-concepts-and-terminologys:~:text=topics)
and their
[partitions](https://kafka.apache.org/42/getting-started/introduction/#main-concepts-and-terminologys:~:text=partitioned).
Inspect the request and response layouts:

- [DescribeTopicPartitions Request (v0)](https://binspec.org/kafka-describe-topic-partitions-request-v0)
- [DescribeTopicPartitions Response (v0) - Unknown Topic](https://binspec.org/kafka-describe-topic-partitions-response-v0-unknown-topic)

### Parsing the request

The
[`DescribeTopicPartitions` request (v0)](https://kafka.apache.org/42/design/protocol/#The_Messages_DescribeTopicPartitions)
contains:

| Field                      | Data type          | Description                              |
| -------------------------- | ------------------ | ---------------------------------------- |
| `topics`                   | `COMPACT_ARRAY`    | Array of topics to get metadata for      |
| `response_partition_limit` | `INT32`            | Maximum number of partitions to return   |
| `cursor`                   | Nullable structure | Starting position for a continued lookup |
| `TAG_BUFFER`               | `TAGGED_FIELDS`    | Tagged fields                            |

Each topic in the `topics` array contains:

| Field        | Data type        | Description    |
| ------------ | ---------------- | -------------- |
| `topic_name` | `COMPACT_STRING` | The topic name |
| `TAG_BUFFER` | `TAGGED_FIELDS`  | Tagged fields  |

A `COMPACT_STRING` contains a UTF-8 byte length plus one, encoded as an unsigned
variable-length integer, followed by the string bytes. Thus `foo` is
`04 66 6f 6f`. The request uses header v2, as with `ApiVersions`. Its
`client_id` uses the older `NULLABLE_STRING` format: a signed two-byte length
followed by bytes, with `-1` for null.

The cursor supports pagination, which divides a large result across requests.
Here the cursor is null, represented by the single byte `ff`, and no pagination
is required. A non-null cursor would contain a topic name and partition index.

### Response header v1

The
[response header v1](https://kafka.apache.org/42/design/protocol/#the-messages)
adds `TAG_BUFFER` to the `correlation_id` from header v0:

| Field            | Data type       | Description                          |
| ---------------- | --------------- | ------------------------------------ |
| `correlation_id` | `INT32`         | Matches the request's correlation ID |
| `TAG_BUFFER`     | `TAGGED_FIELDS` | Tagged fields                        |

Leave `TAG_BUFFER` empty.

### The `DescribeTopicPartitions` response body

The `DescribeTopicPartitions` response body has the following structure:

| Field              | Data type          | Description                                    |
| ------------------ | ------------------ | ---------------------------------------------- |
| `throttle_time_ms` | `INT32`            | Throttle time in milliseconds (use `0`)        |
| `topics`           | `COMPACT_ARRAY`    | Array of topic metadata                        |
| `next_cursor`      | Nullable structure | Pagination cursor (use the byte `ff` for null) |
| `TAG_BUFFER`       | `TAGGED_FIELDS`    | Tagged fields                                  |

Each topic in the `topics` array contains:

| Field                         | Data type        | Description                                     |
| ----------------------------- | ---------------- | ----------------------------------------------- |
| `error_code`                  | `INT16`          | Error code                                      |
| `topic_name`                  | `COMPACT_STRING` | The topic name (from the request)               |
| `topic_id`                    | `UUID`           | Topic UUID                                      |
| `is_internal`                 | `BOOLEAN`        | Whether topic is internal                       |
| `partitions`                  | `COMPACT_ARRAY`  | Array of partition metadata (empty for unknown) |
| `topic_authorized_operations` | `INT32`          | Authorized operations bitfield (use `0`)        |
| `TAG_BUFFER`                  | `TAGGED_FIELDS`  | Tagged fields                                   |

A topic UUID is a 16-byte identifier. Its hyphenated text form is only a display
format. The wire response contains the 16 bytes. A boolean occupies one byte,
with `00` for false.

For this stage, you should treat all topics as unknown. For an unknown topic,
your response should:

- Set `error_code` to `3` (`UNKNOWN_TOPIC_OR_PARTITION`).
- Echo back the `topic_name` from the request.
- Set `topic_id` to `00000000-0000-0000-0000-000000000000` (all zeros).
- Set `is_internal` to `false`.
- Leave the `partitions` array empty.
- Set `next_cursor` to `-1` (null).

Here's an example of what your response might look like for a topic named
`"foo"`:

```java
00 00 00 29  // message_size:                 41 bytes
ab cd ef 12  // correlation_id:               (matches request)
00           // TAG_BUFFER:                   empty (response header v1)
00 00 00 00  // throttle_time_ms:             0
02           // topics array:                 1 element
00 03        // error_code:                   3 (UNKNOWN_TOPIC_OR_PARTITION)
04           // name length:                  3 (compact string)
66 6f 6f     // topic_name:                         "foo"
00 00 00 00  // topic_id:                     00000000-0000-0000-
00 00 00 00  //                               0000-000000000000
00 00 00 00  //                               (16 bytes total)
00 00 00 00  //
00           // is_internal:                  false
01           // partitions array:             0 elements (empty)
00 00 00 00  // topic_authorized_operations:  0
00           // TAG_BUFFER:                   empty
ff           // next_cursor:                  -1 (null)
00           // TAG_BUFFER:                   empty
```

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It will then connect to your server on port `9092` and send a
`DescribeTopicPartitions` (v0) request containing a single topic name.

```
echo -n "00000020004b00000000000700096b61666b612d636c69000204666f6f0000000064ff00" | xxd -r -p | nc localhost 9092 | hexdump -C
```

The tester will validate that:

- The `message_size` field correctly represents the size of the header and body.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The response uses response header v1 (with `TAG_BUFFER`).
- The `error_code` in the response body is `3` (`UNKNOWN_TOPIC_OR_PARTITION`).
- The response body should be a valid DescribeTopicPartitions (v0) Response.
- The `topic_name` field in the response should be equal to the topic name sent
  in the request.
- The `topic_id` field in the response should be equal to
  `00000000-0000-0000-0000-000000000000`.
- The `partitions` field in the response should be empty.
- The value of `next_cursor` is `-1`, indicating that the cursor is null.
