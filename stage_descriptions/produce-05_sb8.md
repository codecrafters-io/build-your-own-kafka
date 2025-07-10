In this stage, you'll add support for producing multiple records from a single request with multiple record batches in the payload.

## Batch Processing

Your Kafka implementation should handle multiple records in a single batch, assign sequential offsets, and validate the LastOffsetDelta field correctly. The RecordBatch containing multiple records must be stored atomically to the log file.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request containing a RecordBatch with multiple records.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (NO_ERROR).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic response matches the topic name in the request.
- The `partition` field in the partition response matches the partition in the request.
- The `offset` field in the partition response contains the base offset for the batch.
- The `timestamp` field in the partition response contains a valid timestamp.
- The `log_start_offset` field in the partition response is correct.

The tester will also verify that the record is persisted to the appropriate log file on disk at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log` with sequential offsets.

## Notes

- Records within a batch must be assigned sequential offsets (e.g., if base offset is 5, records get offsets 5, 6, 7).
- The entire batch is treated as a single atomic operation.
- The response should return the base offset of the batch, not individual record offsets.
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce).
