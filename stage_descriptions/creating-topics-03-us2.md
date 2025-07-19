In this stage, you'll add support for handling `CreateTopics` requests with existing topic names.

## CreateTopics API response for existing topics

When a Kafka broker receives a CreateTopics request, it needs to validate that the topic doesn't already exist and is not reserved for system use. If a topic already exists or is reserved, it returns an appropriate error code and response without attempting to create the topic again.

To validate that a topic exists, the broker reads the `__cluster_metadata` topic's log file, located at `/tmp/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log`. Inside the log file, the broker finds the topic's metadata, which is a `record` (inside a RecordBatch) with a payload of type `TOPIC_RECORD`. If there exists a `TOPIC_RECORD` with the given topic name and the topic ID, the topic exists.

If the topic already exists, the broker returns an error code of `36` (TOPIC_ALREADY_EXISTS), with the `error_message` field containing `Topic '<topic_name>' already exists.`.

Reserved topic names include:
- `__cluster_metadata` - KRaft metadata topic

If the topic name is reserved, the broker returns an error code of `42` (INVALID_REQUEST), with the `error_message` field containing `Creation of internal topic __cluster_metadata is prohibited.`.

We've created an interactive protocol inspector for the request & response structures for `CreateTopics`:

- 🔎 [CreateTopics Request (v6)](https://binspec.org/kafka-createtopics-request-v6)
- 🔎 [CreateTopics Response (v6)](https://binspec.org/kafka-createtopics-response-v6)

We've also created an interactive protocol inspector for the `__cluster_metadata` topic's log file:
- 🔎 [__cluster_metadata topic's log file](https://binspec.org/kafka-cluster-metadata)

This would help you understand the structure of the `TOPIC_RECORD` record inside the `__cluster_metadata` topic's log file.

In this stage, you'll need to implement topic existence checking by reading the cluster metadata.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `CreateTopics` (v6) request for an existing topic and a reserved topic name.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic response is `36` (TOPIC_ALREADY_EXISTS) or `42` (INVALID_REQUEST) depending on the request.
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic response corresponds to the topic name in the request.
- The `error_message` field contains the expected error message.
- The `num_partitions` and `replication_factor` fields are `-1`.

## Notes

- The official Kafka docs don't cover the structure of records inside the `__cluster_metadata` topic, but you can find the definitions in the Kafka source code [here](https://github.com/apache/kafka/tree/trunk/metadata/src/main/resources/common/metadata).