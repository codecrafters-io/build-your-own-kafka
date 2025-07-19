In this stage, you'll add support for handling `CreateTopics` requests in validation mode.

## Validation-Only Mode

When a Kafka broker receives a CreateTopics request with the `validate_only` flag set to `true`, it needs to perform all validation checks as if creating the topics but without actually creating them or modifying any persistent state. This allows clients to validate topic creation parameters without side effects.

The broker performs the following steps:
1. Validates the topic name
2. Checks that the topic doesn't already exist
3. Validates partition count and replication factor parameters
4. Returns success/error responses as if creating the topics
5. Does NOT write any `TOPIC_RECORD` to the `__cluster_metadata` topic's log file
6. Does NOT create any partition directories in the log directory
7. Does NOT modify any persistent state (e.g. topic metadata, partition files, etc.)

The response should be identical to what would be returned for actual topic creation, but without any persistence side effects.

We've created an interactive protocol inspector for the request & response structures for `CreateTopics`:

- 🔎 [CreateTopics Request (v6)](https://binspec.org/kafka-createtopics-request-v6)
- 🔎 [CreateTopics Response (v6)](https://binspec.org/kafka-createtopics-response-v6)

In this stage, you'll need to check the `validate_only` flag in the request and modify your behavior accordingly.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `CreateTopics` (v6) request with `validate_only` set to `true`.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic result is `0` (NO_ERROR) for valid topics.
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic result corresponds to the topic name in the request.
- NO topic metadata is written to the `__cluster_metadata` topic's log file.
- NO topic directories are created in the log directory.
- The response is identical to what would be returned for actual topic creation.

## Notes

- This stage tests the ability to perform dry-run validation without side effects.
- All validation logic from previous stages should be applied.
- The response should be identical to actual topic creation, but without persistence.