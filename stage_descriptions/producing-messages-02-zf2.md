In this stage, you'll implement the Produce response for invalid topics or partitions. And that would be all.

## Produce API Response for Invalid Topics or Partitions

When a Kafka broker receives a `Produce` request, it needs to validate that both the topic and partition exist. If either the topic or partition doesn't exist, it returns an appropriate error code and response.

For this stage, you can hardcode the error response - assume that all `Produce` requests are for invalid topics or partitions and return the error code `3` (UNKNOWN_TOPIC_OR_PARTITION). In the next stage, you'll implement handling success responses.

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v11)](example.com)
- 🔎 [Produce Response (v11) - Invalid Topic](example.com)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request with either an invalid topic name or a valid topic but invalid partition.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `throttle_time_ms` field in the response is `0`.
- The `topics` field has 1 element, and in that element:
  - The `name` field matches the topic name in the request.
  - The `partitions` field has 1 element, and in that element:
    - The `error_code` is `3` (UNKNOWN_TOPIC_OR_PARTITION).
    - The `index` field matches the partition in the request.
    - The `base_offset` field is `-1`.
    - The `log_append_time_ms` field is `-1`.
    - The `log_start_offset` field is `-1`.

## Notes

- You'll need to parse the `Produce` request in this stage to get the topic name and partition to send in the response.
- You can hardcode the error response in this stage. We'll get to actually checking for valid topics and partitions in later stages.
- The official docs for the `Produce` API can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "(Version: 11)" section.
