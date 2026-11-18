Your broker stores a batch containing one record. In this stage, you'll store a
batch containing several records, preserving the whole batch in the destination
partition's log.

### Producing multiple records

A record's offset is its position within a partition. A batch stores a base
offset, and each record stores an offset delta relative to it. For example, base
offset `0` and deltas `0`, `1`, `2` identify three successive records. The
incoming batch already encodes these deltas for this stage, so preserve its
bytes and checksum. The `RecordBatch` containing multiple records must be stored
as a single unit to the topic's log file at
`<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log`.

We've created an interactive protocol inspector for the request and response
structures for `Produce`:

- [Produce Request (v11)](https://binspec.org/kafka-produce-request-v11)
- [Produce Response (v11)](https://binspec.org/kafka-produce-success-response)

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11)
request containing a RecordBatch with multiple records.

The tester will validate that:

<!-- prettier-ignore -->
- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the
  request header.
- The `throttle_time_ms` field in the response is `0`.
- The `topics` field has 1 element, and in that element:
    - The `name` field matches the topic name in the request.
    - The `partitions` field has 1 element, and in that element:
        - The `error_code` is `0` (`NO_ERROR`).
        - The `index` field matches the partition in the request.
        - The `base_offset` field is 0 (the base offset for the batch).
        - The `log_append_time_ms` field is `-1` (no broker append timestamp is
          supplied).
        - The `log_start_offset` field is `0`.
- The RecordBatch sent in the request is written in
  `<log-dir>/<topic-name>-<partition-index>/00000000000000000000.log`.

### Notes

- The on-disk log files must be stored in
  [RecordBatch](https://kafka.apache.org/42/implementation/message-format/#record-batchh)
  format. You should write each `RecordBatch` from the request directly to the
  log file of the appropriate topic's partition.
- See the
  [Produce API schemas](https://kafka.apache.org/42/design/protocol/#The_Messages_Produce),
  under "(Version: 11)".
