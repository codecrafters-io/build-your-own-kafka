In this stage, you'll add support for handling CreateTopics requests with reserved topic names.

## CreateTopics API response for reserved topics

When a Kafka broker receives a CreateTopics request, it needs to validate that the topic name is not reserved for system use. If a client tries to create a topic with a reserved name, the broker returns an appropriate error code and response without attempting to create the topic.

Reserved topic names include:
- `__cluster_metadata` - KRaft metadata topic
- Topics starting with `__` (double underscore) - System topics

The broker validates this by checking if the topic name starts with `__` or matches specific reserved patterns.

If the topic name is reserved, the broker returns an error code of `42` (INVALID_REQUEST).

We've created an interactive protocol inspector for the request & response structures for `CreateTopics`:

- 🔎 [CreateTopics Request (v7)](https://binspec.org/kafka-createtopics-request-v7)
- 🔎 [CreateTopics Response (v7)](https://binspec.org/kafka-createtopics-response-v7)

We've also created an interactive protocol inspector for the `__cluster_metadata` topic's log file:
- 🔎 [__cluster_metadata topic's log file](https://binspec.org/kafka-cluster-metadata)

In this stage, you'll need to check if the topic name is reserved before allowing creation.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send a `CreateTopics` (v7) request with a reserved topic name.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic response is `42` (INVALID_REQUEST).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic response corresponds to the topic name in the request.
- The `error_message` field contains a descriptive error message.
- The `num_partitions` and `replication_factor` fields are `-1`.

## Notes

- This stage focuses on detecting reserved topic names, particularly `__cluster_metadata`.
- The `__cluster_metadata` topic is automatically created by the KRaft system and should not be manually created.