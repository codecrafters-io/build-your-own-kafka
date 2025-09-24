In this stage, you'll implement the `DescribeTopicPartitions` response for multiple topics.

🚧 **We're still working on instructions for this stage**. You can find notes on how the tester works below.

In the meantime, please use
[this link](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+WQ2+%28DescribeTopicPartition+with+multiple+topics%29&body=%3Cyour+question+here%3E)
to ask questions on the forum.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `DescribeTopicPartitions` (v0) request. The request will contain 2 topic names. The topics exist and have 1 or 2 partitions assigned to each.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The topics are sorted alphabetically by topic name.
- The error code in the topic response body is `0` (NO_ERROR).
- The `topic_name` field in the topic response should be equal to the topic name sent in the request.
- The `topic_id` field in the topic response should be equal to the topic UUID of the topic.
- The partition response should contain details of the partitions assigned to the topic.
- The error code in all the partition responses should be `0` (NO_ERROR).
- The `partition_index` field in all the partition responses should be equal to the partition ID of the partition assigned to the topic.
- The value of `cursor` is -1, indicating that the cursor is null.


### Notes

- The official docs for the `DescribeTopicPartitions` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions).