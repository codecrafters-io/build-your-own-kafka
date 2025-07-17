In this stage, you'll add support for handling `CreateTopics` requests with invalid topic names.

## CreateTopics API response for invalid topics

When a Kafka broker receives a CreateTopics request, it first needs to validate that the topic name follows Kafka's naming rules. If a topic name is invalid, it returns an appropriate error code and response without attempting to create the topic.

Topic names must follow these rules:
- Cannot be empty string
- Cannot be "." or ".."
- Maximum length of 249 characters
- Only ASCII alphanumerics, '.', '_', and '-' are allowed

If the topic name is invalid, the broker returns an error code of `17` (INVALID_TOPIC_EXCEPTION).

We've created an interactive protocol inspector for the request & response structures for `CreateTopics`:

- 🔎 [CreateTopics Request (v6)](https://binspec.org/kafka-createtopics-request-v6)
- 🔎 [CreateTopics Response (v6)](https://binspec.org/kafka-createtopics-response-v6)

In this stage, you'll need to implement basic topic name validation without needing to check against existing topics or system topics. You can hard code the error response for invalid topic names in this stage. 

## Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send a `CreateTopics` (v6) request with an invalid topic name.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the topic response is `17` (INVALID_TOPIC_EXCEPTION).
- The `throttle_time_ms` field in the response is `0`.
- The `name` field in the topic response corresponds to the topic name in the request.
- The `error_message` field contains a descriptive error message.
- The `num_partitions` and `replication_factor` fields are `-1`.

## Notes

- You'll need to parse the `CreateTopics` request in this stage to get the topic names.
- The official docs for the `CreateTopics` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_CreateTopics).
- Topic name validation logic is in the Kafka source code at `clients/src/main/java/org/apache/kafka/common/internals/Topic.java`.