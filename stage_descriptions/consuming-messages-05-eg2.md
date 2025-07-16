In this stage, you'll implement the Fetch response for a topic with a single message, reading it from disk.

🚧 **We're still working on instructions for this stage**. You can find notes on how the tester works below.

In the meantime, please use
[this link](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+eg2%3A+Fetch+single+message+from+disk&body=%3Cyour+question+here%3E)
to ask questions on the forum.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh
```

It'll then connect to your server on port 9092 and send a `Fetch` (v16) request. The request will contain a single topic with a topic ID that exists. The topic has a single message assigned to it.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (No Error).
- The `throttle_time_ms` field in the response is `0`.
- The `responses` field in the response has 1 element, and in that element:
  - The `topic_id` field matches what was sent in the request.
  - The `partitions` array has 1 element, and in that element:
    - The `partition_index` field is `0`.
    - The `error_code` field is `0` (No Error).
    - The `records` array has 1 element.
      - The entire `RecordBatch` content is read from disk. (We will compare the contents of the `RecordBatch` with the contents of the log file to verify this.)

### Notes

- You'll need to parse the `Fetch` request in this stage to get the `topic_id` to send in the response.
- The official docs for the `Fetch` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Fetch). Make sure
  to scroll down to the "Fetch Response (Version: 16)" section.