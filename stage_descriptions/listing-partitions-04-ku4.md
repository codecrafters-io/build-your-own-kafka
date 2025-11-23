In this stage, you'll implement the `DescribeTopicPartitions` response for a topic with multiple partitions.

### Handling Multiple Partitions

When a topic has multiple partitions, each partition gets its own entry in the `partitions` array. The structure of each [partition entry](https://binspec.org/kafka-describe-topic-partitions-response-v0?highlight=38-65) remains the same as with previous stages.

For this stage, you'll respond with metadata for a topic that has two partitions. Each partition should have its own entry with the correct `partition_index`.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It will then send a `DescribeTopicPartitions` (v0) request for a topic that has two partitions.

The tester will verify that:
- The `message_size` field is correct.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `error_code` in the topic entry is `0` (no error).
- The response is a valid `DescribeTopicPartitions` (v0) response.
- The `topic_name` field matches the topic name sent in the request.
- The `topic_id` matches the actual UUID from the cluster metadata.
- The `partitions` array contains exactly two partition entries.
- Both partition entries have `error_code` of `0` (no error).
- Each `partition_index` matches the actual partition IDs from the metadata.
- The `next_cursor` value is `-1` (null).

### Notes

- Each partition should have its own complete entry in the `partitions` array with the correct `partition_index`.
- The official [`DescribeTopicPartitions` documentation](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions) contains the complete response schema.
