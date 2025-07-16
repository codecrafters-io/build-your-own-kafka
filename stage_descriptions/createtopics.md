# Kafka / CreateTopics API

## Stage 1: Include CreateTopics in APIVersions

In this stage, you'll add an entry for the `CreateTopics` API to the APIVersions response.

### APIVersions

Your Kafka implementation should include the CreateTopics API (key=19) in the ApiVersions response before implementing topic creation functionality. This lets the client know that the broker supports the CreateTopics API.

### Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send a valid `APIVersions` (v4) request.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (No Error).
- The response body contains at least one entry for the API key `19` (CreateTopics).
- The `MaxVersion` for the CreateTopics API is at least 7.

### Notes

- You don't have to implement support for the `CreateTopics` request in this stage. We'll get to this in later stages.
- You'll still need to include the entry for `APIVersions` in your response to pass the previous stage.

## Stage 2: CreateTopics with Invalid Topic Names

In this stage, you'll add support for handling CreateTopics requests with invalid topic names and return proper error responses.

### Handling Invalid Topic Names

Your Kafka implementation should validate topic names and return appropriate error codes when a client tries to create topics with invalid names. Topic names must follow these rules:
- Cannot be empty string
- Cannot be "." or ".."
- Maximum length of 249 characters
- Only ASCII alphanumerics, '.', '_', and '-' are allowed
- Cannot have period/underscore collision patterns

### Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send a `CreateTopics` (v6) request with an invalid topic name.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic result is `17` (INVALID_TOPIC_EXCEPTION).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic result corresponds to the topic name in the request.
- The `error_message` field contains a descriptive error message.

### Notes

- You'll need to parse the `CreateTopics` request in this stage to get the topic names.
- The official docs for the `CreateTopics` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_CreateTopics).
- Topic name validation logic is in the Kafka source code at `clients/src/main/java/org/apache/kafka/common/internals/Topic.java`.

## Stage 3: CreateTopics with Invalid Partition/Replication Parameters

In this stage, you'll add support for handling CreateTopics requests with invalid partition counts and replication factors.

### Handling Invalid Parameters

Your Kafka implementation should validate numeric parameters and return appropriate errors:
- Partition count must be greater than 0 (or -1 for defaults)
- Replication factor must be greater than 0 (or -1 for defaults)
- Both parameters cannot be 0 or negative (except -1)

### Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send `CreateTopics` (v6) requests with invalid parameters.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic result is `37` (INVALID_PARTITIONS) for invalid partition count.
- The error code in the topic result is `38` (INVALID_REPLICATION_FACTOR) for invalid replication factor.
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic result corresponds to the topic name in the request.
- The `error_message` field contains a descriptive error message.

### Notes

- Test cases will include: partition count = 0, partition count = -2, replication factor = 0, replication factor = -2.
- Valid values are positive integers or -1 (for broker defaults).

## Stage 4: CreateTopics with Existing Topics

In this stage, you'll add support for detecting when a topic already exists and return the appropriate error response.

### Handling Existing Topics

Your Kafka implementation should check if a topic already exists before attempting to create it. You can check for existing topics by:
- Looking for topic directories in the log directory (e.g., `/tmp/kraft-combined-logs/topic-name-0/`)
- Reading the `__cluster_metadata` topic for TopicRecord entries

### Tests

The tester will execute your program like this:

```bash
./your_program.sh
# Create a topic first
# Then try to create the same topic again
```

It'll then connect to your server on port 9092 and send a `CreateTopics` (v6) request for an existing topic.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic result is `36` (TOPIC_ALREADY_EXISTS).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic result corresponds to the topic name in the request.
- The `error_message` field contains a descriptive error message.

### Notes

- This stage requires basic topic existence checking without full topic creation logic.
- You can use filesystem checks or metadata parsing to detect existing topics.

## Stage 5: CreateTopics with Invalid Manual Assignment

In this stage, you'll add support for validating manual partition assignments and return appropriate error responses.

### Handling Invalid Manual Assignment

Your Kafka implementation should validate manual partition assignments when provided:
- Manual assignment requires partition count and replication factor to be -1
- Partition indices must be consecutive starting from 0
- Replica lists cannot be empty
- Broker IDs must be valid (though you can mock this validation)
- No duplicate broker IDs within a partition assignment

### Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send `CreateTopics` (v6) requests with invalid manual assignments.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic result is `39` (INVALID_REPLICA_ASSIGNMENT).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic result corresponds to the topic name in the request.
- The `error_message` field contains a descriptive error message.

### Notes

- Test cases include: non-(-1) partition count with assignment, non-consecutive partitions, empty replica lists, duplicate broker IDs.
- Manual assignment validation is complex but can be implemented without broker state.

## Stage 6: CreateTopics with Authorization Failure

In this stage, you'll add support for authorization checks and return appropriate error responses.

### Handling Authorization

Your Kafka implementation should check authorization before creating topics:
- Require CREATE permission on CLUSTER resource or specific TOPIC resource
- You can implement a simple authorization check based on configuration or mock it
- Return authorization failure for unauthorized requests

### Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send `CreateTopics` (v6) requests without proper authorization.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic result is `29` (TOPIC_AUTHORIZATION_FAILED).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic result corresponds to the topic name in the request.
- The `error_message` field contains "Authorization failed."

### Notes

- This stage focuses on authorization error handling rather than implementing full ACL logic.
- You can use a simple configuration-based approach to determine authorization.

---

## Setup Commands

```bash
# Clean environment
rm -rf /tmp/kafka-logs /tmp/zookeeper /tmp/kraft-combined-logs

# Generate cluster ID and format storage
KAFKA_CLUSTER_ID="$(/usr/local/kafka-latest/bin/kafka-storage.sh random-uuid)"
/usr/local/kafka-latest/bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c /usr/local/kafka-latest/config/kraft/server.properties

# Start Kafka server
/usr/local/kafka-latest/bin/kafka-server-start.sh /usr/local/kafka-latest/config/kraft/server.properties

# Test with Kafka CLI
/usr/local/kafka-latest/bin/kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092 --partitions 3
```

## Testing Commands

```bash
# Build tester
make build

# Run individual test
go run main.go

# Verify with Kafka CLI
/usr/local/kafka-latest/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

## Error Code Reference

| Code | Name | Stages |
|------|------|---------|
| 0 | NO_ERROR | Success cases |
| 17 | INVALID_TOPIC_EXCEPTION | 2 |
| 29 | TOPIC_AUTHORIZATION_FAILED | 6 |
| 36 | TOPIC_ALREADY_EXISTS | 4 |
| 37 | INVALID_PARTITIONS | 3 |
| 38 | INVALID_REPLICATION_FACTOR | 3 |
| 39 | INVALID_REPLICA_ASSIGNMENT | 5 |