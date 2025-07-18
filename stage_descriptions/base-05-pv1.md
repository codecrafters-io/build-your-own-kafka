In this stage, you'll implement the response body for the `APIVersions` request.

We've created an interactive protocol inspector for the `APIVersions` request & response:

- 🔎 [API Versions Request (v4)](https://binspec.org/kafka-api-versions-request-v4)
- 🔎 [API Versions Response (v4)](https://binspec.org/kafka-api-versions-Response-v4)

🚧 **We're still working on instructions for this stage**. You can find notes on how the tester works below.

In the meantime, please use
[this link](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+pv1%3A+Handle+APIVersions+requests&body=%3Cyour+question+here%3E)
to ask questions on the forum.

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
- The response body contains at least one entry for the API key `18` (API_VERSIONS).
- The `MaxVersion` for the `ApiKey` `18` is at least `4`.

### Notes

- The tester will always send you v4 of the APIVersions request.
  - As of Oct 30th 2024, v4 is "unreleased" so isn't available in the Kafka docs yet. It'll
    be available once Kafka 3.9 is released. Here's a link to the [Kafka source code](https://github.com/apache/kafka/blob/84caaa6e9da06435411510a81fa321d4f99c351f/clients/src/main/resources/common/message/ApiVersionsRequest.json#L25C22-L25C33) mentioning this.
  - The structure for v4 is the same as v3 listed in the docs.
- From this stage onwards, the tester will start validating the first 4 bytes of your response (the "message length") in addition to the other checks.
- If extra bytes are remaining after decoding all the fields of the response body, this will be considered an error.