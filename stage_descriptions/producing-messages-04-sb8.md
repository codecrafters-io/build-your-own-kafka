In this stage, you'll add support for producing multiple records from a single request, with multiple records inside a single RecordBatch.

## Batch Processing

When a Kafka broker receives a Produce request containing a RecordBatch with multiple records, it needs to validate that the topic and partition exist, assign sequential offsets to each record within the batch, and store the entire batch atomically to the log file. The RecordBatch containing multiple records must be stored as a single unit to the topic's log file at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log`.

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v11)](https://binspec.org/kafka-produce-request-v11)
- 🔎 [Produce Response (v11)](https://binspec.org/kafka-produce-response-v11)

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
- The topic response contains:
  - The `name` field matches the topic name in the request.
  - The partition response contains:
    - The `index` field matches the partition in the request.
    - The `base_offset` field contains 0 (the base offset for the batch).
    - The `log_append_time_ms` field contains `-1` (signifying that the timestamp is the latest).
    - The `log_start_offset` field is `0`.
- The records are persisted to the appropriate log file on disk at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log` with sequential offsets.

## Notes

- Records within a batch must be assigned sequential offsets (e.g., if the base offset is 5, records get offsets 5, 6, 7).
- The response should return the base offset of the batch, not individual record offsets.
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "Produce Response (Version: 11)" section.

TODO: Send multiple request per stage from stage 5 onwards. (Need to test how baseOffset & log_start_offset are handled by kafka.)