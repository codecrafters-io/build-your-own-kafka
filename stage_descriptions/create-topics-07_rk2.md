In this stage, you'll add support for successfully creating topics with valid parameters.

## Single Topic Creation

When a Kafka broker receives a CreateTopics request for a valid topic name that doesn't already exist, it needs to validate the parameters, create the topic metadata, persist it to the `__cluster_metadata` topic, create the topic directory structure, and return a successful response.

The broker performs the following steps:
1. Validates the topic name (from previous stages)
2. Checks that the topic doesn't already exist (from previous stages)
3. Validates partition count and replication factor parameters (request will include valid values)
4. Creates a new topic UUID
5. Writes a `TOPIC_RECORD` to the `__cluster_metadata` topic's log file
6. Writes `PARTITION_RECORD`s to the `__cluster_metadata` topic's log file
7. Creates partition directories in the log directory (e.g., `/tmp/kraft-combined-logs/topic-name-0/`)
8. Nested structure inside the `__cluster_metadata` topic's log file:
TODO
9.  Returns a successful response with error code `0` (NO_ERROR)

We've created an interactive protocol inspector for the request & response structures for `CreateTopics`:

- 🔎 [CreateTopics Request (v7)](https://binspec.org/kafka-createtopics-request-v7)
- 🔎 [CreateTopics Response (v7)](https://binspec.org/kafka-createtopics-response-v7)

We've also created an interactive protocol inspector for the `__cluster_metadata` topic's log file:
- 🔎 [__cluster_metadata topic's log file](https://binspec.org/kafka-cluster-metadata)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send a `CreateTopics` (v7) request with valid parameters.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic response is `0` (NO_ERROR).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic response corresponds to the topic name in the request.
- The topic metadata is written to the `__cluster_metadata` topic.
- The topic directory structure is created in the log directory.
- The `num_partitions` and `replication_factor` fields in the topic response correspond to the request.

## Notes

- The topic metadata should be persisted in the `__cluster_metadata` topic as a `TOPIC_RECORD`.
- Topic directories should be created in the log directory (e.g., `/tmp/kraft-combined-logs/topic-name-0/`).