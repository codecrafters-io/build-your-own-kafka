In this stage, you'll add support for producing to multiple topics in a single request.

## Producing to multiple topics

When a Kafka broker receives a `Produce` request targeting multiple topics with their respective partitions, it needs to validate that all topics and partitions exist, write records to each topic-partition's log file independently, and return a nested response structure containing results for all topics and their partitions. 

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v12)](https://binspec.org/kafka-produce-request-v12)
- 🔎 [Produce Response (v12)](https://binspec.org/kafka-produce-response-v12)

You can refer to the following interactive protocol inspector for Kafka's log file format:
- 🔎 [A sample topic's log file](https://binspec.org/kafka-topic-log)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v12) request targeting multiple topics with their respective partitions. The request will contain data for multiple topics, spanning multiple partitions for each topic. 

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `throttle_time_ms` field in the response is `0`.
- The `topics` field has `N` elements, one for each of the `N` topics in the request:
  - The `name` field matches the topic name in the request.
  - The `partitions` field has `M` elements, one for each of the `M` partitions in the request:
    - The `error_code` is `0` (NO_ERROR).
    - The `index` field matches the partition in the request.
    - The `base_offset` field contains the assigned offset for that topic-partition.
    - The `log_append_time_ms` field is `-1` (signifying that the timestamp is the latest).
    - The `log_start_offset` field is `0`.
- Records are persisted to the correct topic-partition log files on disk.

## Notes

- The official docs for the `Produce` API can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "(Version: 12)" section.