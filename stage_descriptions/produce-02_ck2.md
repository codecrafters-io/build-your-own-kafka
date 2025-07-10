In this stage, you'll add support for handling Produce requests to non-existent topics.

## Produce API response for non-existent topics

When a Kafka broker receives a Produce request, it first needs to validate that the topic exists. If a topic doesn't exist, it returns an appropriate error code and response. 
To validate that a topic exists, the broker reads the `__cluster_metadata` topic's log file, located at `/tmp/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log`. Inside the log file, the broker finds the topic's metadata, which is a `record` (inside a RecordBatch) with a payload of type `TOPIC_RECORD`. If there exists a `TOPIC_RECORD` with the given topic name and the topic ID, the topic exists. Else, the topic doesn't exist.

If the topic doesn't exist, the broker returns an error code of `3` (UNKNOWN_TOPIC_OR_PARTITION).

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v11)](https://binspec.org/kafka-produce-request-v11)
- 🔎 [Produce Response (v11)](https://binspec.org/kafka-produce-response-v11)

We've also created an interactive protocol inspector for the `__cluster_metadata` topic's log file:
- 🔎 [__cluster_metadata topic's log file](https://binspec.org/kafka-cluster-metadata)

This would help you understand the structure of the `TOPIC_RECORD` record inside the `__cluster_metadata` topic's log file.

In this stage, you'll need to implement the response for a `Produce` request with a non-existent topic.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request with a non-existent topic.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `error_code` in the response body is `3` (UNKNOWN_TOPIC_OR_PARTITION).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the nested `topic` response inside the top level response body should correspond to the topic name in the request.
- The `index` field in the nested `partition` response inside the nested `topic` response should correspond to the partition in the request.
- The `base_offset` field in the partition response inside topic response should be `-1`.
- The `log_append_time_ms` field in the partition response inside topic response should be `-1`.
- The `log_start_offset` field in the partition response inside topic response should be `-1`.

## Notes

- You'll need to parse the `Produce` request in this stage to get the topic name and partition to send in the response.
- The official docs for the `Produce` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "Produce Response (Version: 11)" section.
- The official Kafka docs don't cover the structure of records inside the `__cluster_metadata` topic, but you can find the definitions in the Kafka source code [here](https://github.com/apache/kafka/tree/5b3027dfcbcb62d169d4b4421260226e620459af/metadata/src/main/resources/common/metadata).
