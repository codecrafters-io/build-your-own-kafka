Your broker can now handle repeated requests on one connection. Extend it to
serve several clients whose connections overlap in time.

One client may keep its connection open while another sends a request. Waiting
for the first client's next request must not prevent the second client from
receiving a response. Each connection keeps its own request bytes and
correlation IDs. The concurrency mechanism is your choice.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then instantiate 2-3 clients. Each of these clients will connect to your
server on port 9092 and send multiple `ApiVersions` (v4) requests.

For each response, the tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The error code in the response body is `0` (No Error).
- The response body contains at least one entry for the API key `18`
  (ApiVersions).
- For `ApiVersions`, `MinVersion` is `0` and `MaxVersion` is `4`.

### Notes

- The tester will only send ApiVersions (v4) requests in this stage.
- If extra bytes are remaining after decoding all the fields of the response
  body, this will be considered an error.
