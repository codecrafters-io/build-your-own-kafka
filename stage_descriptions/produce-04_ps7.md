In this stage, you'll add support for successfully producing a single record to a valid topic and partition.

## Single Record Production

Your Kafka implementation should accept valid Produce requests, store the record in the appropriate log file, and return successful responses with assigned offsets. The record must be persisted to the topic's log file at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log` using Kafka's on-disk log format.

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
- The `partition` field in the partition response matches the partition in the request.
- The `offset` field in the partition response contains the assigned offset to the record. (The offset is the offset of the record in the partition, not the offset of the batch. So 0 for the first record, 1 for the second record, and so on.)
- The `timestamp` field in the partition response contains -1 (signifying that the timestamp is latest).
- The `log_start_offset` field in the partition response is `0`.

The tester will also verify that the record is persisted to the appropriate log file on disk at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log`.

## Notes

- You'll need to implement log file writing using Kafka's binary log format.
- Records must be stored in RecordBatch format with proper CRC validation.
- The offset assignment should start from 0 for new partitions.
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce).
