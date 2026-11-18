Your broker can identify an empty topic. In this stage, you'll return the single
stored message for an existing topic by reading its partition's log.

### From a topic ID to stored bytes

The metadata log associates the requested UUID with a topic name. The
partition's data is stored at
`/tmp/kraft-combined-logs/<topic-name>-<partition-index>/00000000000000000000.log`.
Here the requested partition is `0`.

Kafka stores messages in `RecordBatch` containers, which include metadata such
as offsets and a checksum as well as the records. The Fetch `records` field
carries those encoded batches. Preserve the complete batch from disk, including
its header. Returning just the message's text loses information the client needs
to decode it.

The compact length before `records` is the number of batch bytes plus one. It is
not a count of messages. In this stage, the file contains one batch with one
message. The
[record-batch format](https://kafka.apache.org/42/implementation/message-format/#record-batchh)
describes the stored bytes.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Fetch` (v16) request.
The request will contain a single topic with a topic ID that exists. The topic
has a single message assigned to it.

The tester will validate that:

<!-- prettier-ignore -->
- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The error code in the response body is `0` (No Error).
- The `throttle_time_ms` field in the response is `0`.
- The `responses` field in the response has 1 element, and in that element:
    - The `topic_id` field matches what was sent in the request.
    - The `partitions` array has 1 element, and in that element:
        - The `partition_index` field is `0`.
        - The `error_code` field is `0` (No Error).
        - The `records` field contains one complete record batch.
            - The entire `RecordBatch` content is read from disk. (We will compare the
              contents of the `RecordBatch` with the contents of the log file to
              verify this.)

### Notes

- You'll need to parse the `Fetch` request in this stage to get the `topic_id`
  to send in the response.
- See the
  [Fetch response schema](https://kafka.apache.org/42/design/protocol/#The_Messages_Fetch),
  under "Fetch Response (Version: 16)".

For questions about this stage,
[ask on the forum](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+eg2%3A+Fetch+single+message+from+disk&body=%3Cyour+question+here%3E).
