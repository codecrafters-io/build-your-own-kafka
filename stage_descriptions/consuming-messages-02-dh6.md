In this stage, you'll implement the Fetch response for a Fetch request with no topics.

🚧 **We're still working on instructions for this stage**. You can find notes on how the tester works below.

In the meantime, please use
[this link](https://forum.codecrafters.io/new-topic?category=Challenges&tags=challenge%3Akafka&title=Question+about+dh6%3A+Fetch+with+no+topics&body=%3Cyour+question+here%3E)
to ask questions on the forum.

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