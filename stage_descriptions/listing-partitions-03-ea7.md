In this stage, you'll implement the `DescribeTopicPartitions` response for a single topic.

Kafka stores metadata about topics in the `__cluster_metadata` topic. To check if a topic exists or not, you'll need to read
the `__cluster_metadata` topic's log file, located at `/tmp/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log`.

We've created an interactive protocol inspector for the cluster metadata log file and the `DescribeTopicPartitions` response:

- 🔎 [Cluster Metadata Log File](https://binspec.org/kafka-cluster-metadata)
- 🔎 [DescribeTopicPartitions Response (v0)](https://binspec.org/kafka-describe-topic-partitions-response-v0)

🚧 **We're still working on instructions for this stage**. You can find notes on how the tester works below.

In the meantime, please use
[this link](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+ea7%3A+List+for+a+single+partition&body=%3Cyour+question+here%3E)
to ask questions on the forum.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `DescribeTopicPartitions` (v0) request. The request will contain an single topic name. The topic exists and has a single partition assigned to it.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is 0 (no error).
- The response body should be valid DescribeTopicPartitions (v0) Response.
- The `topic_name` field in the response should match the topic name sent in the request.
- The `topic_id` field in the response should match the topic UUID of the topic.
- The `partitions` field in the response should contain details of the partition assigned to the topic.
- The error code in the partition response should be 0 (no error).
- The `partition_index` field in the partition response should match the partition ID of the partition assigned to the topic.

### Notes

- The official docs for the `DescribeTopicPartitions` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions).
- The official Kafka docs don't cover the structure of records inside the `__cluster_metadata` topic, but you can find the definitions in the Kafka source code [here](https://github.com/apache/kafka/tree/5b3027dfcbcb62d169d4b4421260226e620459af/metadata/src/main/resources/common/metadata).