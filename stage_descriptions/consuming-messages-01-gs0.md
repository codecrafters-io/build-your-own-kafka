In this stage, you'll add an entry for the `Fetch` API to the ApiVersions response.

🚧 **We're still working on instructions for this stage**. You can find notes on how the tester works below.

In the meantime, please use
[this link](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+gs0%3A+Include+Fetch+in+ApiVersions&body=%3Cyour+question+here%3E)
to ask questions on the forum.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh
```

It'll then connect to your server on port 9092 and send a valid `ApiVersions` (v4) request.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (No Error).
- The response body contains at least one entry for the API key `1` (FETCH).
- The `MaxVersion` for the Fetch API is atleast 16.

### Notes

- You don't have to implement support for the `Fetch` request in this stage. We'll get to this in later stages.
- You'll still need to include the entry for `ApiVersions` in your response to pass the previous stage.
- The `MaxVersion` for the `Fetch` and `ApiVersions` are different. For `ApiVersions`, it is 4. For `Fetch`, it is 16.
