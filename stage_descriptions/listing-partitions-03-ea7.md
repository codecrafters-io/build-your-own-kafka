In this stage, you'll implement the `DescribeTopicPartitions` response for a single topic.

### The `DescribeTopicPartitions` API (Recap)

As a recap, the [`DescribeTopicPartitions`](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions) API returns metadata about [topics](https://kafka.apache.org/documentation/#intro_concepts_and_terms) and their [partitions](https://kafka.apache.org/documentation/#:~:text=partitioned). In previous stages, you treated all topics as unknown. For this stage, you'll read actual topic metadata (from a cluster metadata log) and send a valid response for that topic.

We've created an interactive protocol inspector for the cluster metadata format and the `DescribeTopicPartitions` response structure:

- 🔎 [Cluster Metadata Log File](https://binspec.org/kafka-cluster-metadata)
- 🔎 [DescribeTopicPartitions Response (v0)](https://binspec.org/kafka-describe-topic-partitions-response-v0)

### Understanding the Cluster Metadata Log

Kafka stores metadata about topics in the `__cluster_metadata` topic. This is an internal topic that contains records about topic creation, partition assignments, and other cluster configuration. To check if a topic exists and get its metadata, you'll need to read the cluster metadata log file.

The log file is located at:
```
/tmp/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log
```

You'll need to parse this file to extract:
- Topic names and their UUIDs
- Partition IDs for each topic

The Kafka documentation doesn't cover the internal structure of `__cluster_metadata` records in detail, but you can find the schema definitions in the [Kafka source code](https://github.com/apache/kafka/tree/5b3027dfcbcb62d169d4b4421260226e620459af/metadata/src/main/resources/common/metadata).

### Building the Response for Existing Topics

When a topic exists, your response should contain complete metadata about it. The key differences from the `"unknown topic"` response are:

- Set `error_code` to `0` (no error).
- Use the actual `topic_id` (UUID) from the cluster metadata, not all zeros.
- Include partition information in the `partitions` array.

Each partition entry in the `partitions` array contains:

| Field                              | Data type       | Description                                    |
| ---------------------------------- | --------------- | ---------------------------------------------- |
| `error_code`                       | `INT16`         | Error code (0 for valid partitions)            |
| `partition_index`                  | `INT32`         | The partition ID                               |
| `leader_id`                        | `INT32`         | The broker ID hosting this partition           |
| `leader_epoch`                     | `INT32`         | The leader epoch                               |
| `replica_nodes`                    | `COMPACT_ARRAY` | Array of replica broker IDs                    |
| `isr_nodes`                        | `COMPACT_ARRAY` | Array of in-sync replica broker IDs            |
| `eligible_leader_replicas`         | `COMPACT_ARRAY` | Array of eligible leader replica broker IDs    |
| `last_known_elr`                   | `COMPACT_ARRAY` | Array of last known eligible leader replicas   |
| `offline_replicas`                 | `COMPACT_ARRAY` | Array of offline replica broker IDs            |
| `TAG_BUFFER`                       | `TAGGED_FIELDS` | Tagged fields                                  |

For this stage, the tester will send requests for topics with a single partition.

Here's an example response for a topic named `"foo"` with one partition:

```
00 00 00 4a  // message_size:                 74 bytes
ab cd ef 12  // correlation_id:               (matches request)
00           // TAG_BUFFER:                   empty (response header v1)
00 00 00 00  // throttle_time_ms:             0
02           // topics array:                 1 element
00 00        // error_code:                   0 (no error)
04           // name length:                  3 (compact string)
66 6f 6f     // name:                         "foo"
a1 b2 c3 d4  // topic_id:                     (actual UUID from metadata)
e5 f6 a7 b8  //                               (16 bytes total)
c9 d0 e1 f2  //
a3 b4 c5 d6  //
00           // is_internal:                  false
02           // partitions array:             1 element
00 00        // error_code:                   0 (no error)
00 00 00 00  // partition_index:              0
00 00 00 01  // leader_id:                    1
00 00 00 00  // leader_epoch:                 0
02           // replica_nodes:                1 element
01           //                               broker 1
02           // isr_nodes:                    1 element
01           //                               broker 1
01           // eligible_leader_replicas:     0 elements (empty)
01           // last_known_elr:               0 elements (empty)
01           // offline_replicas:             0 elements (empty)
00           // TAG_BUFFER:                   empty
00 00 00 00  // topic_authorized_operations:  0
00           // TAG_BUFFER:                   empty
ff           // next_cursor:                  -1 (null)
00           // TAG_BUFFER:                   empty
```

### Tests

The tester will execute your program like this:

```bash
$ ./your_program.sh /tmp/server.properties
```

It will then send a `DescribeTopicPartitions` (v0) request for a topic that exists with a single partition.

The tester will verify that:
- The `message_size` field correctly represents the size of the header and body.
- The correlation ID in the response header matches the correlation ID in the request header.
- The `error_code` in the topic entry is `0` (no error).
- The response is a valid `DescribeTopicPartitions` (v0) response.
- The `topic_name` field matches the topic name sent in the request.
- The `topic_id` matches the actual UUID from the cluster metadata.
- The `partitions` array contains one partition entry.
- The partition `error_code` is `0` (no error).
- The `partition_index` matches the partition ID from the metadata.
- The `next_cursor` value is `-1` (null).

### Notes

- You'll need to parse the cluster metadata log file to extract the topic and partition information.
- The official Kafka protocol documentation doesn't detail the `__cluster_metadata` structure. Refer to the [Kafka source code](https://github.com/apache/kafka/tree/5b3027dfcbcb62d169d4b4421260226e620459af/metadata/src/main/resources/common/metadata) for schema definitions.
- The official [`DescribeTopicPartitions` documentation](https://kafka.apache.org/protocol.html#The_Messages_DescribeTopicPartitions) contains the complete response schema.
