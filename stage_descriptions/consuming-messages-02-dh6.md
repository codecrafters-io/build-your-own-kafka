In this stage, you'll implement the response for a `Fetch` request with no topics.

### Fetch API response for no topics

A `Fetch` request includes a list of topics to fetch messages from. If the request contains an empty list of topics, the `responses` field in the response will be an empty array.

Here are interactive visualizations of what the `Fetch` request & response will look like when the request contains an empty list of topics:

- 🔎 [Fetch Request (v17) with no topics](https://binspec.org/kafka-fetch-request-v17-no-topics)
- 🔎 [Fetch Response (v17) with no topics](https://binspec.org/kafka-fetch-response-v17-no-topics)

In this stage, you'll need to implement the response for a `Fetch` request with an empty list of topics. We'll get to handling `Fetch` requests with topics in later stages.

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh
```

It'll then connect to your server on port 9092 and send a `Fetch` (v16) request. The request will contain an empty array of topics.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The error code in the response body is `0` (No Error).
- The `throttle_time_ms` field in the response is `0`.
- The `session_id` field in the response is `0`.
- The `responses` field in the response has 0 elements (since the request had an empty array of topics).

<!--
```
0000   00 00 00 11 5e 33 46 cc 00 00 00 00 00 00 00 0a   ....^3F.........
0010   b9 c1 2e 01 00                                    .....
```
-->

### Notes

- You don't need to parse the fields in the `Fetch` request in this stage, we'll get to this in later stages.
- The official docs for the `Fetch` request can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Fetch). Make sure
  to scroll down to the "Fetch Response (Version: 16)" section.
