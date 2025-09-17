In this stage, you'll add support for producing multiple records in a single `Produce` request.

## Producing multiple records

When a Kafka broker receives a `Produce` request containing a `RecordBatch` with multiple records, it needs to validate that the topic and partition exist, assign sequential offsets to each record within the batch, and store the entire batch to the log file. The `RecordBatch` containing multiple records must be stored as a single unit to the topic's log file at `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log`.

We've created an interactive protocol inspector for the request & response structures for `Produce`:

- 🔎 [Produce Request (v11)](example.com)
- 🔎 [Produce Response (v11)](example.com)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request containing a RecordBatch with multiple records.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `throttle_time_ms` field in the response is `0`.
- The `topics` field has 1 element, and in that element:
  - The `name` field matches the topic name in the request.
  - The `partitions` field has 1 element, and in that element:
    - The `error_code` is `0` (NO_ERROR).
    - The `index` field matches the partition in the request.
    - The `base_offset` field is 0 (the base offset for the batch).
    - The `log_append_time_ms` field is `-1` (signifying that the timestamp is the latest).
    - The `log_start_offset` field is `0`.
  
- The RecordBatch sent in the request is written in `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log`.

The tester will then send a Fetch Request specifying the topic and partition and validate the response against following conditions:

- The `responses` field in the response has 1 element, and in that element:
  - The `topic_id` field matches what was sent in the request.
  - The `partitions` array has 1 element, and in that element:
    - The `partition_index` field matches what was sent in the request.
    - The `error_code` field is `0` (No Error).
    - The entire `RecordBatch` content is read from disk. (The tester will compare the contents of the `RecordBatch` with the contents of the corresponding log file to verify this.)


## Notes

- The on-disk log files must be stored in [RecordBatch](https://kafka.apache.org/documentation/#recordbatch) format. You should write each `RecordBatch` from the request directly to the log file of the appropriate topic's partition.
- The official docs for the `Produce` API can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "(Version: 11)" section.