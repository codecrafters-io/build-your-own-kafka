In this stage, you'll implement the `DescribeTopicPartitions` response for an unknown topic.

We've created an interactive protocol inspector for the `DescribeTopicPartitions` request & response:

- 🔎 [DescribeTopicPartitions Request (v0)](https://binspec.org/kafka-describe-topic-partitions-request-v0)
- 🔎 [DescribeTopicPartitions Response (v0) - Unknown Topic](https://binspec.org/kafka-describe-topic-partitions-response-v0-unknown-topic)

🚧 **We're still working on instructions for this stage**. You can find notes on how the tester works below.

In the meantime, please use
[this link](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+vt6%3A+List+for+an+unknown+topic&body=%3Cyour+question+here%3E)
to ask questions on the forum.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `DescribeTopicPartitions` (v0) request. The request will contain a single topic with 1 partition.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is 3 (`UNKNOWN_TOPIC_OR_PARTITION`).
- The response body should be valid DescribeTopicPartitions (v0) Response.
- The `topic_name` field in the response should be equal to the topic name sent in the request.
- The `topic_id` field in the response should be equal to `00000000-0000-0000-0000-000000000000`.
- The `partitions` field in the response should be empty. (As there are no partitions assigned to this non-existent topic.)

### Notes

- You'll need to parse the `DescribeTopicPartitions` request in this stage to get the topic name to send in the response.
- For now, you can assume that all topics are "unknown". We'll work on identifying actual vs. unknown topics in later stages.
- The official docs for the `DescribeTopicPartitions` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions).