In this stage, you'll add support for producing to multiple topics in a single request.

## Cross-Topic Production

Your Kafka implementation should handle complex requests with multiple topics, manage independent offset tracking per topic and partition, and handle complex response structures. Each topic maintains completely independent offset sequences.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request targeting multiple topics with their respective partitions.

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
    - The correct `partition` field matching the request.
    - An error code of `0` (NO_ERROR).
    - A valid `offset` field with the assigned offset for that topic-partition.
    - A valid `timestamp` field.
    - A correct `log_start_offset` field.
- Records are persisted to the correct topic-partition log files.
- Offset assignment is independent per topic-partition combination.

## Notes

- Each topic-partition combination maintains its own independent offset sequence.
- Multiple topics can be written to simultaneously in a single request.
- The response structure is nested: topics contain partition responses.
- Topic-level and partition-level errors should be handled independently.
- This is the most complex produce scenario, combining multi-topic and multi-partition handling.
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce).
