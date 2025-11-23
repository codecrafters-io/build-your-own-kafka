In this stage, you'll implement the `DescribeTopicPartitions` response for multiple topics.

### Handling Multiple Topics

In previous stages, you responded with metadata for a single topic. Now you'll handle requests that ask about multiple topics at once.

The `DescribeTopicPartitions` request can include multiple topic names in the `topics` array. Your response should include a corresponding entry for each requested topic in the response's `topics` array.

The topics in your response must be **sorted alphabetically** by topic name. This ensures consistent ordering regardless of how the client sends the request.

For example, if a client requests topics `"zebra"` and `"apple"`, your response should list `"apple"` first, then `"zebra"`.

### Tests

The tester will execute your program like this:
```bash
$ ./your_program.sh /tmp/server.properties
```

It will then send a `DescribeTopicPartitions` (v0) request with two topic names. Each topic will have one or two partitions.

The tester will verify that:
- The `message_size` field correctly represents the size of the header and body.
- The correlation ID in the response header matches the correlation ID in the request header.
- The topics are sorted alphabetically by topic name.
- Each topic entry has an `error_code` of `0` (no error).
- Each `topic_name` matches one of the requested topics.
- Each `topic_id` matches the actual UUID from the cluster metadata.
- Each topic's `partitions` array contains the correct partition entries.
- All partition entries have an `error_code` of `0` (no error).
- Each `partition_index` matches the actual partition IDs from the metadata.
- The `next_cursor` value is `-1` (null).

### Notes

- Topics must be sorted alphabetically by name in the response.
- Each topic in the request gets its own complete entry in the response's `topics` array.
- The official [`DescribeTopicPartitions` documentation](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions) contains the complete response schema.
