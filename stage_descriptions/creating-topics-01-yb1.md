In this stage, you'll add an entry for the `CreateTopics` API to the APIVersions response.

## The CreateTopics API

The [CreateTopics API](https://kafka.apache.org/protocol#The_Messages_CreateTopics) (API key `19`) is used to create topics in a Kafka cluster. We'll use a single broker in our cluster for this extension.

We've created an interactive protocol inspector for the request & response structures for `CreateTopics`:

- 🔎 [CreateTopics Request (v6)](https://binspec.org/kafka-createtopics-request-v6)
- 🔎 [CreateTopics Response (v6)](https://binspec.org/kafka-createtopics-response-v6)

In this stage, you'll only need to add an entry for the `CreateTopics` API to the APIVersions response you implemented in earlier stages. This will let the client know that the broker supports the `CreateTopics` API. We'll get to responding to `CreateTopics` requests in later stages.

## Tests

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
- The `MaxVersion` for the CreateTopics API is at least 6.

## Notes

- You don't have to implement support for the `CreateTopics` request in this stage. We'll get to this in later stages.
- You'll still need to include the entry for `APIVersions` in your response to pass previous stages.
- The `MaxVersion` for the `CreateTopics` API is 7.
