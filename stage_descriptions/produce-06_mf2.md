In this stage, you'll add support for producing to multiple partitions of the same topic in a single request.

## Partition Routing

Your Kafka implementation should handle writes to multiple partitions within the same topic, manage independent offset assignment per partition, and aggregate responses correctly. Each partition maintains its own offset sequence independently.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request targeting multiple partitions of the same topic.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (NO_ERROR).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic response matches the topic name in the request.
- Each partition in the request has a corresponding partition response.
- Each partition response contains:
  - The correct `partition` field matching the request.
  - An error code of `0` (NO_ERROR).
  - A valid `offset` field with the assigned offset for that partition.
  - A valid `timestamp` field.
  - A correct `log_start_offset` field.
- Records are persisted to the correct partition log files.
- Offset assignment is independent per partition (partition 0 and partition 1 can both have offset 0).

## Notes

- Each partition maintains its own offset sequence starting from 0.
- Multiple partitions can be written to simultaneously in a single request.
- The response must include entries for all requested partitions.
- Partition-level errors should be handled independently (one partition failure shouldn't affect others).
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce).
