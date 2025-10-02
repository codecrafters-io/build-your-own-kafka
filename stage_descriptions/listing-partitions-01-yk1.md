In this stage, you'll add an entry for the `DescribeTopicPartitions` API to the ApiVersions response.

🚧 **We're still working on instructions for this stage**. You can find notes on how the tester works below.

In the meantime, please use
[this link](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+yk1%3A+Include+DescribeTopicPartitions+in+ApiVersions&body=%3Cyour+question+here%3E)
to ask questions on the forum.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a valid `ApiVersions` (v4) request.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (No Error).
- The response body contains at least one entry for the API key 18 (`ApiVersions`) and one entry for the API key 75 (`DescribeTopicPartitions`).
- The response for the API key 18 (`ApiVersions`) has a `MaxVersion` of at least 4, and a `MinVersion` of at least 0.
- The response for the API key 75 (`DescribeTopicPartitions`) has a `MaxVersion` of at least 0, and a `MinVersion` of at least 0.

### Notes

- The `MaxVersion` for the `DescribeTopicPartitions` and `ApiVersions` are different. For `ApiVersions`, it is 4. For `DescribeTopicPartitions`, it is 0.
- You'll still need to include the entry for `ApiVersions` in your response to pass previous stages.
- We'll get to implementing the `DescribeTopicPartitions` request in later stages, in this stage you only need to add an entry to the ApiVersions response.
