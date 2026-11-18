Replace the always-error shortcut with metadata validation. For an existing
topic and partition, send a successful Produce response. Writing the received
record batch to disk starts in the next stage.

### Produce response for valid topics

When a Kafka broker receives a `Produce` request, it needs to validate that both
the topic and partition exist. If either the topic or partition doesn't exist,
it returns an appropriate error code and response.

The supplied metadata identifies topics and the partitions belonging to each
topic. A partition index alone does not identify a destination, because
different topics can each have partition `0`. If you completed Listing
Partitions, this uses the same metadata log.

### Topic validation

To validate that a topic exists, the broker reads the `__cluster_metadata`
topic's log file, located at
`/tmp/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log`. The
file contains `RecordBatch` containers, each holding records. A record's value
carries a typed metadata payload. A `TOPIC_RECORD` maps a topic name to its
UUID, a 16-byte identifier. Match the requested name to obtain that UUID.

The batch header's length counts bytes after its four-byte length field. Record
fields use signed zigzag variable-length integers, while metadata payloads use
the compact encodings shown in the inspector. Zigzag maps `0`, `-1`, `1`, `-2`
to unsigned `0`, `1`, `2`, `3` before variable-length encoding.

The inspector's record layout is the outer envelope. It contains the record
length, attributes, timestamp and offset deltas, then length-prefixed key and
value bytes, followed by headers. The value length bounds the metadata payload
inside that envelope. That payload begins with a frame version, a record type
and a record version. The type and version select the `TopicRecord` or
`PartitionRecord` schema. Those schemas describe the contents of the value, so
their fields start after the payload's three-byte prefix. Other metadata record
types can appear in the same log.

### Partition validation

To validate that a partition exists, the broker reads the same
`__cluster_metadata` topic's log file and finds the partition's metadata, which
is a `record` (inside a RecordBatch) with a payload of type `PARTITION_RECORD`.

A partition is considered to exist if there is a PARTITION_RECORD that matches:

- the requested partition ID,
- the UUID of the topic it belongs to,
- the UUID of the log directory where the partition is stored.

The supplied log directory's `meta.properties` contains `directory.id` in
URL-safe Base64 form. Metadata partition records store the same identifier as 16
UUID bytes. These are two representations of the same value.

We've also created an interactive protocol inspector for the
`__cluster_metadata` topic's log file:

- [Cluster Metadata Log File](https://binspec.org/kafka-cluster-metadata)

A successful response reports `base_offset` `0` and `log_start_offset` `0` for
this stage's initially empty partition. Keep `log_append_time_ms` at `-1`,
meaning no broker append timestamp is supplied. The previous stage's
unknown-topic-or-partition behavior remains required for invalid destinations.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11)
request with a valid topic and partition.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The `throttle_time_ms` field in the response is `0`.
- The `topics` field has 1 element, and in that element:
  - The `name` field matches the topic name in the request.
  - The `partitions` field has 1 element, and in that element:
    - The `error_code` is `0` (NO_ERROR).
    - The `index` field matches the partition in the request.
    - The `base_offset` field is `0` (signifying that this is the first record
      in the partition).
    - The `log_append_time_ms` field is `-1` (no broker append timestamp is
      supplied).
    - The `log_start_offset` field is `0`.

### Notes

- The official docs for the `Produce` API can be found
  [here](https://kafka.apache.org/42/design/protocol/#The_Messages_Produce).
  Make sure to scroll down to the "(Version: 11)" section.
- The official Kafka docs don't cover the structure of records inside the
  `__cluster_metadata` topic, but you can find the definitions in the Kafka
  source code
  [here](https://github.com/apache/kafka/tree/5b3027dfcbcb62d169d4b4421260226e620459af/metadata/src/main/resources/common/metadata).
