In this stage, you'll add an entry for the `Fetch` API to the APIVersions response.

### The Fetch API

The [Fetch API](https://kafka.apache.org/protocol#The_Messages_Fetch) (API key `1`) is used to fetch messages from a Kafka topic.

We've created an interactive protocol inspector for the request & response structures for `Fetch`:

- 🔎 [Fetch Request (v16)](https://binspec.org/kafka-fetch-request-v16)
- 🔎 [Fetch Response (v16)](https://binspec.org/kafka-fetch-response-v16)

In this stage, you'll only need to add an entry for the `Fetch` API to the APIVersions response you implemented in earlier stages. We'll get to responding to `Fetch` requests in later stages.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh
```

It'll then connect to your server on port 9092 and send a valid `APIVersions` (v4) request.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (No Error).
- The response body contains at least one entry for the API key `1` (FETCH).
- The `MaxVersion` for the Fetch API is atleast 16.

### Notes

- You don't have to implement support for handling `Fetch` requests in this stage. We'll get to this in later stages.
- You'll still need to include the entry for `APIVersions` in your response to pass earlier stages.
- The `MaxVersion` for the `Fetch` and `APIVersions` are different. For `APIVersions`, it is 4. For `Fetch`, it is 16.
