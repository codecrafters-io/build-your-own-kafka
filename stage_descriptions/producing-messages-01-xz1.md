The Producing Messages extension lets clients write events to your broker's
partition logs. In this stage, you'll advertise `Produce` in your existing
`ApiVersions` response so clients can discover the supported request format.

### The Produce API

The
[Produce API](https://kafka.apache.org/42/design/protocol/#The_Messages_Produce)
(API key `0`) writes messages to a topic, a named event stream. A request
addresses one or more partitions, the separate ordered logs within that topic.

Advertise `min_version` `0` and `max_version` at least `11`. Retain your
existing API entries.

We've created an interactive protocol inspector for the request and response
structures for `Produce`:

- [Produce Request (v11)](https://binspec.org/kafka-produce-request-v11)
- [Produce Response (v11)](https://binspec.org/kafka-produce-success-response)

In this stage, you'll only need to add an entry for the `Produce` API to the
ApiVersions response you implemented in earlier stages. This lets clients know
that your broker supports the `Produce` API. We'll get to responding to
`Produce` requests in later stages.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a valid `ApiVersions`
(v4) request.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The error code in the response body is `0` (`NO_ERROR`).
- The response body contains at least one entry for the API key `0` (`Produce`).
- The `MaxVersion` for the `Produce` API is at least 11.

### Notes

- You don't have to implement support for handling `Produce` requests in this
  stage. We'll get to this in later stages.
- You'll still need to include the entry for `ApiVersions` in your response to
  pass earlier stages.
- Choose `max_version` for each API independently: at least `4` for
  `ApiVersions`, and at least `11` for `Produce`.
