Your broker advertises `Fetch`. Now handle a `Fetch` v16 request with no topics.
An empty result establishes the response format before you add message lookup.

### The Fetch response

`Fetch` uses API key `1` and request header v2. Its response uses header v1: the
request's four-byte correlation ID followed by a tag buffer. An empty tag buffer
is `00`. Keep `ApiVersions` on response header v0.

After the Fetch response header, the body contains these fields in order:

| Field              | Encoding        | Meaning in this stage                                          |
| ------------------ | --------------- | -------------------------------------------------------------- |
| `throttle_time_ms` | `INT32`         | Use `0`, with no delay applied                                 |
| `error_code`       | `INT16`         | Use `0` for success                                            |
| `session_id`       | `INT32`         | Identifies a fetch session. Use `0` when no session is created |
| `responses`        | `COMPACT_ARRAY` | No topic results. An empty array is `01`                       |
| `TAG_BUFFER`       | Tagged fields   | Use `00` for no tags                                           |

The four-byte `message_size` counts the response header and body, excluding
itself. You can ignore the request body for this increment.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Fetch` (v16) request.
The request will contain an empty array of topics.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The error code in the response body is `0` (No Error).
- The `throttle_time_ms` field in the response is `0`.
- The `responses` field in the response has 0 elements (since the request had an
  empty array of topics).

### Notes

- You don't need to parse the fields in the `Fetch` request in this stage, we'll
  get to this in later stages.
- The official docs for the `Fetch` request can be found
  [here](https://kafka.apache.org/42/design/protocol/#The_Messages_Fetch). Make
  sure to scroll down to the "Fetch Response (Version: 16)" section.

For questions about this stage,
[ask on the forum](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+dh6%3A+Fetch+with+no+topics&body=%3Cyour+question+here%3E).
