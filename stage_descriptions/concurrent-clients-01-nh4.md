In this stage, you'll add support for handling multiple sequential requests from the same client.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh
```

It'll then connect to your server on port 9092 and send a `ApiVersions` (v4) request, read the response, & validate the response.

Once a response is received, the tester will re-use the same connection to send multiple other `ApiVersions` (v4) requests.

For each response, the tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (No Error).
- The response body contains at least one entry for the API key `18` (ApiVersions).
- The `MaxVersion` for the `ApiKey` `18` is at least `4`.

### Notes

- The tester will only send ApiVersions (v4) requests in this stage.
- If extra bytes are remaining after decoding all the fields of the response body, this will be considered an error.
