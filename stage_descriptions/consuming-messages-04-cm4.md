An existing topic can have an empty log. In this stage, you'll distinguish that
successful Fetch with no records from an unknown-topic error.

### Finding an existing topic

The tester supplies topic metadata in
`/tmp/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log`. This
binary log maps a topic's UUID to its name and partitions. If you completed
Listing Partitions, reuse the metadata understanding from that extension.

The log contains `RecordBatch` containers, each holding records whose values
describe metadata. `TopicRecord` values associate names with UUIDs, while
`PartitionRecord` values identify partitions belonging to those UUIDs. The
[metadata inspector](https://binspec.org/kafka-cluster-metadata) shows those
nested layouts. A batch's length counts bytes after its four-byte length field,
and record fields use signed zigzag variable-length integers. Zigzag maps `0`,
`-1`, `1`, `-2` to unsigned `0`, `1`, `2`, `3` before variable-length encoding.
These differ from the unsigned compact lengths in Fetch.

The inspector's record layout is the outer envelope. It contains the record
length, attributes, timestamp and offset deltas, then length-prefixed key and
value bytes, followed by headers. The value length bounds the metadata payload
inside that envelope. That payload begins with a frame version, a record type
and a record version. The type and version select the `TopicRecord` or
`PartitionRecord` schema. Those schemas describe the contents of the value, so
their fields start after the payload's three-byte prefix. Other metadata record
types can appear in the same log.

For the existing topic and partition `0`, return no record-batch bytes. An empty
log does not make the topic unknown. Message data comes in later stages.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Fetch` (v16) request.
The request will contain a single topic with a topic ID that exists. However,
the topic has no messages assigned to it (i.e. the log file is empty).

The tester will validate that:

<!-- prettier-ignore -->
- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The error code in the response body is `0` (No Error).
- The `throttle_time_ms` field in the response is `0`.
- The `responses` field in the response has 1 element, and in that element:
    - The `topic_id` field matches what was sent in the request.
    - The `partitions` array has 1 element, and in that element:
        - The `partition_index` field is `0`.
        - The `error_code` field is `0` (No Error).
        - The `records` field contains no record batches.

### Notes

- You'll need to parse the `Fetch` request in this stage to get the `topic_id`
  to send in the response.
- See the
  [Fetch response schema](https://kafka.apache.org/42/design/protocol/#The_Messages_Fetch),
  under "Fetch Response (Version: 16)".

For questions about this stage,
[ask on the forum](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+cm4%3A+Fetch+with+an+empty+topic&body=%3Cyour+question+here%3E).
