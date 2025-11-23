In this stage, you'll implement the `DescribeTopicPartitions` response for an unknown topic.

### The `DescribeTopicPartitions` API (Recap)

As a recap, the [`DescribeTopicPartitions`](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions) API returns metadata about [topics](https://kafka.apache.org/documentation/#intro_concepts_and_terms) and their [partitions](https://kafka.apache.org/documentation/#:~:text=partitioned). For this stage, you'll handle cases where a client requests a topic that doesn't exist.

We've created an interactive protocol inspector for the `DescribeTopicPartitions` request & response:

- 🔎 [DescribeTopicPartitions Request (v0)](https://binspec.org/kafka-describe-topic-partitions-request-v0)
- 🔎 [DescribeTopicPartitions Response (v0) - Unknown Topic](https://binspec.org/kafka-describe-topic-partitions-response-v0-unknown-topic)

### Parsing the Request

To respond correctly, you'll need to parse the `DescribeTopicPartitions` request to extract the topic name. The [`DescribeTopicPartitions` request (v0)](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions) contains:

| Field        | Data type       | Description                           |
| ------------ | --------------- | ------------------------------------- |
| `topics`     | `COMPACT_ARRAY` | Array of topics to get metadata for   |
| `TAG_BUFFER` | `TAGGED_FIELDS`    | Tagged fields                         |

Each topic in the `topics` array contains:

| Field        | Data type    | Description          |
| ------------ | ------------ | -------------------- |
| `topic_name`       | `STRING`     | The topic name       |
| `TAG_BUFFER` | `TAGGED_FIELDS` | Tagged fields        |

For this stage, the tester will send a request with a single topic name. You'll need to extract this name and echo it back in your response.

### Response Header v1

In previous stages, you used response header v0, which only contained the `correlation_id` field. For this stage, you'll use [response header v1](https://kafka.apache.org/protocol.html#protocol_messages), which has the following structure:

| Field            | Data type    | Description                           |
| ---------------- | ------------ | ------------------------------------- |
| `correlation_id` | `INT32`      | Matches the request's correlation ID  |
| `TAG_BUFFER`     | `TAGGED_FIELDS` | Tagged fields         |

The main difference is the addition of the `TAG_BUFFER` field. You can leave the `TAG_BUFFER` empty.

### The `DescribeTopicPartitions` Response Body

The `DescribeTopicPartitions` response body has the following structure:

| Field              | Data type       | Description                                    |
| ------------------ | --------------- | ---------------------------------------------- |
| `throttle_time_ms` | `INT32`         | Throttle time in milliseconds (use `0`)          |
| `topics`           | `COMPACT_ARRAY` | Array of topic metadata                        |
| `next_cursor`      | `NULLABLE_INT8` | Pagination cursor (use `-1` for null)            |
| `TAG_BUFFER`       | `TAGGED_FIELDS`    | Tagged fields                                  |

Each topic in the `topics` array contains:

| Field             | Data type       | Description                                       |
| ----------------- | --------------- | ------------------------------------------------- |
| `error_code`      | `INT16`         | Error code     |
| `topic_name`            | `STRING`        | The topic name (from the request)                 |
| `topic_id`        | `UUID`          | Topic UUID    |
| `is_internal`     | `BOOLEAN`       | Whether topic is internal           |
| `partitions`      | `COMPACT_ARRAY` | Array of partition metadata (empty for unknown)   |
| `topic_authorized_operations`      | `INT32` | Authorized operations bitfield (use `0`)   |
| `TAG_BUFFER`      | `TAGGED_FIELDS`    | Tagged fields                                     |

For this stage, you should treat all topics as unknown. For an unknown topic, your response should:
- Set `error_code` to `3` (`UNKNOWN_TOPIC_OR_PARTITION`).
- Echo back the `topic_name` from the request.
- Set `topic_id` to `00000000-0000-0000-0000-000000000000` (all zeros).
- Set `is_internal` to `false`.
- Leave the `partitions` array empty.
- Set `next_cursor` to `-1` (null).

Here's an example of what your response might look like for a topic named `"foo"`:

```java
00 00 00 2f  // message_size:                 47 bytes
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

It will then connect to your server on port `9092` and send a `DescribeTopicPartitions` (v0) request containing a single topic name.

```
echo -n "00000020004b00000000000700096b61666b612d636c69000204666f6f0000000064ff00" | xxd -r -p | nc localhost 9092 | hexdump -C
```

The tester will validate that:

- The `message_size` field correctly represents the size of the header and body.
- The correlation ID in the response header matches the correlation ID in the request header.
- The response uses response header v1 (with `TAG_BUFFER`).
- The `error_code` in the response body is `3` (`UNKNOWN_TOPIC_OR_PARTITION`).
- The response body should be a valid DescribeTopicPartitions (v0) Response.
- The `topic_name` field in the response should be equal to the topic name sent in the request.
- The `topic_id` field in the response should be equal to `00000000-0000-0000-0000-000000000000`.
- The `partitions` field in the response should be empty.
- The value of `next_cursor` is `-1`, indicating that the cursor is null.

### Notes

- You'll need to parse the `DescribeTopicPartitions` request in this stage to get the topic name to send in the response.
- For now, you can assume that all topics are "unknown". We'll work on identifying actual vs. unknown topics in later stages.
