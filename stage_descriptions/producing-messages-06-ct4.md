In this stage, you'll add support for producing to multiple partitions of the same topic in a single request.

## Producing to multiple partitions

When a Kafka broker receives a `Produce` request targeting multiple partitions of the same topic, it needs to validate that the topic and all partitions exist, write records to each partition's log file independently, and return a response containing results for all partitions.

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v11)](example.com)
- 🔎 [Produce Response (v11)](example.com)

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
  - The `partitions` field has multiple elements (one for each partition in the request), and in each element:
    - The `error_code` is `0` (NO_ERROR).
    - The `index` field matches the partition index in the request.
    - The `base_offset` field is `0` (signifying that this is the first record in each partition).
    - The `log_append_time_ms` field is `-1` (signifying that the timestamp is the latest).
    - The `log_start_offset` field is `0`.
- Each RecordBatch is persisted to the appropriate log file on disk at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log`.

## Notes

- The on-disk log files must be stored in [RecordBatch](https://kafka.apache.org/documentation/#recordbatch) format. You should write each `RecordBatch` from the request directly to the log file of the appropriate topic's partition.
- The official docs for the `Produce` API can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "(Version: 11)" section.