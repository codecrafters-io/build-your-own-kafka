In this stage, you'll add an entry for the `CreateTopics` API to the APIVersions response.

### APIVersions

Your Kafka implementation should include the CreateTopics API (key=19) in the ApiVersions response before implementing topic creation functionality. This lets the client know that the broker supports the CreateTopics API.

### Tests

The tester will execute your program like this:

```bash
./your_program.sh
```

It'll then connect to your server on port 9092 and send a valid `APIVersions` (v4) request.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (No Error).
- The response body contains at least one entry for the API key `19` (CreateTopics).
- The `MaxVersion` for the CreateTopics API is at least 7.

### Notes

- You don't have to implement support for the `CreateTopics` request in this stage. We'll get to this in later stages.
- You'll still need to include the entry for `APIVersions` in your response to pass the previous stage.
