Your empty Fetch response has no topic results. Now return a result for one
requested topic that your broker cannot identify.

### Topic IDs and partition errors

Fetch v16 identifies a topic by its 16-byte UUID. A topic is a named event
stream divided into partitions, each an ordered log. The request groups
partition indexes under a topic UUID, and the response mirrors that grouping.

### Locating the topic in a Fetch request

The body follows request header v2. That header ends with `client_id`, a signed
two-byte byte length followed by UTF-8 bytes (`-1` means null), and a tag
buffer. Its variable length means the body has no fixed offset from the start of
the message.

The v16 body has these field groups in order:

- Request limits: `max_wait_ms`, `min_bytes` and `max_bytes`, each an `INT32`.
- Read mode and session: `isolation_level` is an `INT8`, followed by the `INT32`
  fields `session_id` and `session_epoch`.
- Requested topics: a compact array whose entries begin with a 16-byte
  `topic_id`, followed by a compact array of partition requests and tagged
  fields. Each partition request starts with its `INT32` partition index.
- Remaining context: forgotten topics, the client's rack ID, and tagged fields.

This stage needs the requested topic ID and partition index. The limits, session
and trailing context still occupy bytes even though you don't need to implement
their behavior here. Use the v16 schema for the complete partition layout and
trailing fields.

### Reporting the unknown topic

Parse the requested `topic_id` and include it in a single response entry. Its
partition `0` result has error code `100` (`UNKNOWN_TOPIC_ID`). The top-level
error code remains `0`: the request was handled, but the individual partition
result reports the missing topic. Keep the remaining fields and empty tag
buffers required by the v16 schema, including an empty `records` field.

The
[Fetch v16 schema](https://kafka.apache.org/42/design/protocol/#The_Messages_Fetch)
gives the full field order. Its `records` field contains length-prefixed
record-batch bytes. An empty, non-null value has compact byte length `01`.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Fetch` (v16) request.
This request will contain a single topic with an unknown topic ID (i.e. the
topic doesn't exist yet).

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The error code in the response body is `0` (No Error).
- The `throttle_time_ms` field in the response is `0`.
- The `responses` field in the response has 1 element, and in that element:
  - The `topic_id` field matches what was sent in the request.
  - The `partitions` array has 1 element, and in that element:
    - The `partition_index` field is `0`.
    - The `error_code` field is `100` (UNKNOWN_TOPIC_ID).

### Notes

- You'll need to parse the `Fetch` request in this stage to get the `topic_id`
  to send in the response.
- The official docs for the `Fetch` request can be found
  [here](https://kafka.apache.org/42/design/protocol/#The_Messages_Fetch). Make
  sure to scroll down to the "Fetch Response (Version: 16)" section.

For questions about this stage,
[ask on the forum](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+hn6%3A+Fetch+with+an+unknown+topic&body=%3Cyour+question+here%3E).
