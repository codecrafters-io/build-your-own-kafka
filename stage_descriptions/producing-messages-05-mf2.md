In this stage, you'll add support for producing to multiple partitions of the same topic in a single request.

## Partition Routing

When a Kafka broker receives a Produce request targeting multiple partitions of the same topic, it needs to validate that the topic and all partitions exist, write records to each partition's log file independently, and return a response containing results for all partitions. Each partition maintains its own offset sequence independently, so partition 0 and partition 1 can both have records starting at offset 0.

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v11)](https://binspec.org/kafka-produce-request-v11)
- 🔎 [Produce Response (v11)](https://binspec.org/kafka-produce-response-v11)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request targeting multiple partitions of the same topic.
The request will contain multiple RecordBatches, one for each partition. Each RecordBatch will contain a single record. 

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (NO_ERROR).
- The `throttle_time_ms` field in the response is `0`.
- There is a single topic present in the response.
- The `name` field in the topic response matches the topic name in the request.
- Each partition in the request has a corresponding partition response.
- Each partition response contains:
  - The correct `index` field matching the partition in the request.
  - An error code of `0` (NO_ERROR).
  - A valid `base_offset` field with the assigned offset for that partition.
  - The `log_append_time_ms` field contains `-1` (signifying that the timestamp is latest).
  - The `log_start_offset` field is `0`.
- Records are persisted to the correct partition log files.
- Offset assignment is independent per partition (partition 0 and partition 1 can both have offset 0).

The tester will also verify that the records are persisted to the correct partition log files. 

## Notes

- The response must include entries for all requested partitions.
- On-disk log files must be stored in RecordBatch format with proper CRC validation.
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "Produce Response (Version: 11)" section.
