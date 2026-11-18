Your broker advertises `Produce`. Now answer a v11 request whose target topic or
partition does not exist. This gives clients an explicit failure before you add
successful writes.

### Produce response for invalid topics or partitions

When a Kafka broker receives a `Produce` request, it needs to validate that both
the topic and partition exist. If either the topic or partition doesn't exist,
it returns an appropriate error code and response.

For this stage, assume that all `Produce` requests target invalid topics or
partitions and use error code `3` (`UNKNOWN_TOPIC_OR_PARTITION`). The
correlation ID, topic name and partition index must still come from the request.
Successful writes come later.

Produce v11 uses request header v2 and response header v1. Response header v1
adds an empty tag buffer after the correlation ID. Compact strings prefix their
UTF-8 bytes with an unsigned variable-length byte count plus one, so `foo`
begins with `04`. The response body groups partition results under each topic
name, followed by `throttle_time_ms` and a tag buffer. Each partition result
includes its index, error code, offsets and timestamp fields, plus an empty
`record_errors` array, a nullable `error_message`, and tagged fields. Use
compact encodings for strings and arrays, and include empty tag buffers. The
inspector below shows the full field order.

An offset identifies a record's position within a partition. For this failed
write, use `-1` for `base_offset`, `log_append_time_ms` and `log_start_offset`,
because no successful append position or time is being reported.

We've created an interactive protocol inspector for the request and response
structures for `Produce`:

- [Produce Request (v11)](https://binspec.org/kafka-produce-request-v11)
- [Produce Response (v11) - Invalid Topic or Partition](https://binspec.org/kafka-produce-unknown-topic-or-partition-response-v11)

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send two `Produce` (v11)
requests: the first request will be valid topic but invalid partition, and the
second request will be invalid topic.

For the responses of both requests, the tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The `throttle_time_ms` field in the response is `0`.
- The `topics` field has 1 element, and in that element:
  - The `name` field matches the topic name in the request.
  - The `partitions` field has 1 element, and in that element:
    - The `error_code` is `3` (`UNKNOWN_TOPIC_OR_PARTITION`).
    - The `index` field matches the partition in the request.
    - The `base_offset` field is `-1`.
    - The `log_append_time_ms` field is `-1`.
    - The `log_start_offset` field is `-1`.

### Notes

- You'll need to parse the `Produce` request in this stage to get the topic name
  and partition to send in the response.
- You can keep the error code fixed in this stage. Checking actual topic and
  partition metadata comes next.
- The official docs for the `Produce` API can be found
  [here](https://kafka.apache.org/42/design/protocol/#The_Messages_Produce).
  Make sure to scroll down to the "(Version: 11)" section.
