In this stage, you'll implement adding the Produce API to the APIVersions response.

## The Produce API

The [Produce API](https://kafka.apache.org/protocol#The_Messages_Produce) (API key `0`) is used to produce messages to a Kafka topic.

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v11)](example.com)
- 🔎 [Produce Response (v11)](example.com)

In this stage, you'll only need to add an entry for the `Produce` API to the APIVersions response you implemented in earlier stages. This lets clients know that your broker supports the `Produce` API. We'll get to responding to `Produce` requests in later stages.

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a valid `APIVersions` (v4) request.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (NO_ERROR).
- The response body contains at least one entry for the API key `0` (`Produce`).
- The `MaxVersion` for the `Produce` API is at least 11.

## Notes

- You don't have to implement support for handling `Produce` requests in this stage. We'll get to this in later stages.
- You'll still need to include the entry for `APIVersions` in your response to pass earlier stages.
- The `MaxVersion` for `Produce` and `APIVersions` are different. For `APIVersions`, it is 4. For `Produce`, it is 11.
