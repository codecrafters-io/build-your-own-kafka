In this stage, you'll add support for handling Produce requests to non-existent topics with proper error responses.

## Handling Non-Existent Topics

Your Kafka implementation should validate topic existence and return appropriate error codes when a client tries to produce to a non-existent topic. Kafka stores metadata about topics in the `__cluster_metadata` topic. To check if a topic exists or not, you'll need to read the `__cluster_metadata` topic's log file, located at `/tmp/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log`. If the topic exists, the topic will have a directory with all the data required for it to operate at `<log-dir>/<topic-name>-<partition-index>`.
TODO: Do we need to explain the TOPIC_RECORD record in the `__cluster_metadata` log.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request to a non-existent topic.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `3` (UNKNOWN_TOPIC_OR_PARTITION).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic response inside response should correspond to the topic name in the request.
- The `partition` field in the partition response inside topic response should correspond to the partition in the request.
- The `offset` field in the partition response inside topic response should be `-1`.
- The `timestamp` field in the partition response inside topic response should be `-1`.
- The `log start offset` field in the partition response inside topic response should be `-1`.

## Notes

- You'll need to parse the `Produce` request in this stage to get the topic name and partition to send in the response.
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "Produce Response (Version: 11)" section.
- The official Kafka docs don't cover the structure of records inside the `__cluster_metadata` topic, but you can find the definitions in the Kafka source code [here](https://github.com/apache/kafka/tree/5b3027dfcbcb62d169d4b4421260226e620459af/metadata/src/main/resources/common/metadata).
