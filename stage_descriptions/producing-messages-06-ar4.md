In this stage, you'll add support for producing to multiple topics in a single request.

## Cross-Topic Production

When a Kafka broker receives a Produce request targeting multiple topics with their respective partitions, it needs to validate that all topics and partitions exist, write records to each topic-partition's log file independently, and return a nested response structure containing results for all topics and their partitions. Each topic-partition combination maintains its own independent offset sequence, so topic "foo" partition 0 and topic "bar" partition 0 can both have records starting at offset 0.

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v11)](https://binspec.org/kafka-produce-request-v11)
- 🔎 [Produce Response (v11)](https://binspec.org/kafka-produce-response-v11)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request targeting multiple topics with their respective partitions. The request will contain data for multiple topics, and a single partition for each topic. 

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (NO_ERROR).
- The `throttle_time_ms` field in the response is `0`.
- Each topic in the request has a corresponding topic response.
- Each topic response contains:
  - The correct `name` field matching the topic name in the request.
  - Each partition in the request has a corresponding partition response.
  - Each partition response contains:
    - The correct `index` field matching the partition in the request.
    - An error code of `0` (NO_ERROR).
    - A valid `base_offset` field with the assigned offset for that topic-partition.
    - The `log_append_time_ms` field contains `-1` (signifying that the timestamp is the latest).
    - The `log_start_offset` field is `0`.
- Records are persisted to the correct topic-partition log files on disk.
- Offset assignment is independent per topic-partition combination.

## Notes

- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "Produce Response (Version: 11)" section.
