In this stage, you'll add support for producing to multiple partitions of the same topic in a single request.

## Producing to multiple partitions

When a Kafka broker receives a `Produce` request targeting multiple partitions of the same topic, it needs to validate that the topic and all partitions exist, write records to each partition's log file independently, and return a response containing results for all partitions. Each partition maintains its own offset sequence independently, so partition 0 and partition 1 can both have records starting at offset 0.

You can refer to the following interactive protocol inspector for Kafka's log file format:
- 🔎 [A sample topic's log file](https://binspec.org/kafka-topic-log)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request targeting multiple partitions of the same topic. The request will contain multiple RecordBatches, one for each partition. Each RecordBatch will contain a single record.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `throttle_time_ms` field in the response is `0`.
- The `topics` field has 1 element, and in that element:
  - The `name` field matches the topic name in the request.
  - The `partitions` field has `N` elements, one for each of the `N` partitions in the request:
    - The `error_code` is `0` (NO_ERROR).
    - The `index` field matches the partition in the request.
    - The `base_offset` field contains the assigned offset for that partition.
    - The `log_append_time_ms` field is `-1` (signifying that the timestamp is the latest).
    - The `log_start_offset` field is `0`.
- Records are persisted to the correct partition log files on disk.
- Offset assignment is independent per partition.

## Notes

- The response must include entries for all requested partitions.
- On-disk log files must be stored in `RecordBatch` format.
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "Produce Response (Version: 11)" section.
