In this stage, you'll add support for handling multiple topics in a single CreateTopics request.

## Batch Topic Creation

When a Kafka broker receives a CreateTopics request containing multiple topics, it needs to process each topic independently, applying all validation rules and creation logic to each one. The broker processes each topic in the array and returns individual results for each topic, regardless of whether other topics succeed or fail.

The broker performs the following steps for each topic:
1. Validates the topic name (from previous stages)
2. Checks that the topic doesn't already exist (from previous stages)
3. Validates partition count and replication factor parameters
4. Creates a new topic UUID (for successful topics)
5. Writes a `TOPIC_RECORD` to the `__cluster_metadata` topic's log file (for successful topics)
6. Creates partition directories in the log directory (for successful topics)
7. Returns individual results for each topic in the response array

Mixed success/failure scenarios are handled gracefully - if one topic fails validation, it doesn't prevent other valid topics from being created.

We've created an interactive protocol inspector for the request & response structures for `CreateTopics`:

- 🔎 [CreateTopics Request (v7)](https://binspec.org/kafka-createtopics-request-v7)
- 🔎 [CreateTopics Response (v7)](https://binspec.org/kafka-createtopics-response-v7)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send a `CreateTopics` (v7) request with multiple topics.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The response contains individual results for each topic in the request.
- Each topic result has the correct error code (0 for success, appropriate error codes for failures).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in each topic response corresponds to the topic name in the request.
- Successfully created topics have their metadata written to the `__cluster_metadata` topic.
- Failed topics have appropriate error messages.

## Notes

- The CreateTopics request can contain multiple topics, and each should be processed independently.
- The response should contain a result for each topic in the request, in the same order.