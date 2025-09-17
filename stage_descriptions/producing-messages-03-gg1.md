In this stage, you'll implement the Produce response for a valid topic and a valid partition.

## Produce API Response for Valid Topics

When a Kafka broker receives a `Produce` request, it needs to validate that both the topic and partition exist. If either the topic or partition doesn't exist, it returns an appropriate error code and response.

The broker performs validation in this order:
1. **Topic validation**: Check if the topic exists by reading the `__cluster_metadata` topic's log file
2. **Partition validation**: If the topic exists, check if the partition exists within that topic

### Topic Validation

To validate that a topic exists, the broker reads the `__cluster_metadata` topic's log file, located at `/tmp/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log`. Inside the log file, the broker finds the topic's metadata, which is a `record` (inside a `RecordBatch`) with a payload of type `TOPIC_RECORD`. If there exists a `TOPIC_RECORD` with the given topic name and the topic ID, the topic exists.

### Partition Validation

To validate that a partition exists, the broker reads the same `__cluster_metadata` topic's log file and finds the partition's metadata, which is a `record` (inside a RecordBatch) with a payload of type `PARTITION_RECORD`. If there exists a `PARTITION_RECORD` with the given partition index, the UUID of the topic it is associated with, and the UUID of the directory it is associated with, the partition exists.

We've also created an interactive protocol inspector for the `__cluster_metadata` topic's log file:
- 🔎 [Cluster Metadata Log File](https://binspec.org/kafka-cluster-metadata)

## Tests

The tester will execute your program like this:

```bash
./your_program.sh /tmp/server.properties
```

It'll then connect to your server on port 9092 and send a `Produce` (v11) request with a valid topic and partition.

The tester will validate that:

- The first 4 bytes of your response (the "message length") are valid.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `throttle_time_ms` field in the response is `0`.
- The `topics` field has 1 element, and in that element:
  - The `name` field matches the topic name in the request.
  - The `partitions` field has 1 element, and in that element:
    - The `error_code` is `0` (NO_ERROR).
    - The `index` field matches the partition in the request.
    - The `base_offset` field is `0` (signifying that this is the first record in the partition).
    - The `log_append_time_ms` field is `-1` (signifying that the timestamp is the latest).
    - The `log_start_offset` field is `0`.

## Notes

- The official docs for the `Produce` API can be found [here](https://kafka.apache.org/protocol.html#The_Messages_Produce). Make sure to scroll down to the "(Version: 11)" section.
- The official Kafka docs don't cover the structure of records inside the `__cluster_metadata` topic, but you can find the definitions in the Kafka source code [here](https://github.com/apache/kafka/tree/5b3027dfcbcb62d169d4b4421260226e620459af/metadata/src/main/resources/common/metadata).
