In this stage, you'll add support for successfully producing a single record.

## Single Record Production

When a Kafka broker receives a Produce request for a valid topic and partition, it needs to:

1. **Validate the topic and partition exist** (using the `__cluster_metadata` topic's log file)
2. **Store the record** in the appropriate log file using Kafka's on-disk format
3. **Return a successful response** with the assigned offset

The record must be persisted to the topic's log file at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log` using Kafka's RecordBatch format.

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v11)](https://binspec.org/kafka-produce-request-v11)
- 🔎 [Produce Response (v11)](https://binspec.org/kafka-produce-response-v11)

We've also created an interactive protocol inspector for Kafka's log file format:
- 🔎 [Kafka Log File Format](https://binspec.org/kafka-log-file)

This will help you understand how to write records to the log file in the correct binary format.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send multiple successive `Produce` (v11) requests to a valid topic and partition with single records as payload.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (NO_ERROR).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic response matches the topic name in the request.
- The `index` field in the partition response matches the partition in the request.
- The `base_offset` field in the partition response contains the assigned offset to the record. (The offset is the offset of the record in the partition, not the offset of the batch. So 0 for the first record, 1 for the second record, and so on.)
- The `log_append_time_ms` field in the partition response contains `-1` (signifying that the timestamp is latest).
- The `log_start_offset` field in the partition response is `0`.

The tester will also verify that the record is persisted to the appropriate log file on disk at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log`.

## Notes

- You'll need to implement log file writing using Kafka's binary log format.
- Records must be stored in RecordBatch format with proper CRC validation.
- The offset assignment should start from 0 for new partitions and increment for each subsequent record.
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "Produce Response (Version: 11)" section.
