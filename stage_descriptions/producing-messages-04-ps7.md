In this stage, you'll add support for successfully producing a single record.

## Producing records

When a Kafka broker receives a `Produce` request, it needs to validate that the topic and partition exist (using the `__cluster_metadata` topic's log file), store the record in the appropriate log file using Kafka's on-disk format, and return a successful response with the assigned offset.

The record must be persisted to the topic's log file at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log` using Kafka's RecordBatch format.
You can refer to the official Kafka docs for the [RecordBatch format](https://kafka.apache.org/documentation/#recordbatch).

Kafka's on-disk log format uses the same [RecordBatch](https://binspec.org/kafka-record-batches) format that is used in `Produce` and `Fetch` requests.

You can refer to the following interactive protocol inspector for Kafka's log file format:
- 🔎 [A sample topic's log file](https://binspec.org/kafka-topic-log)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v12) request with a single recordBatch containing a single record.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `throttle_time_ms` field in the response is `0`.
- The `topics` field has 1 element, and in that element:
  - The `name` field matches the topic name in the request.
  - The `partitions` field has 1 element, and in that element:
    - The `error_code` is `0` (NO_ERROR).
    - The `index` field matches the partition in the request.
    - The `base_offset` field contains `0` (signifying that this is the first record in the partition).
    - The `log_append_time_ms` field is `-1` (signifying that the timestamp is the latest).
    - The `log_start_offset` field is `0`.
- The record is persisted to the appropriate log file on disk at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log`.

## Notes

- On-disk log files must be stored in [RecordBatch](https://kafka.apache.org/documentation/#recordbatch) format.
- The official docs for the `Produce` API can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "(Version: 12)" section.