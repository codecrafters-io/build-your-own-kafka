Stage CT1: Include CreateTopics in APIVersions
- Add API key 19 (CreateTopics) to APIVersions response
- Foundation stage enabling API discovery

Stage CT2: CreateTopics with Invalid Topic Name (Hard code error)
- Handle invalid characters, reserved names, empty names
- Error code: INVALID_TOPIC_EXCEPTION (17)

Stage CT3: CreateTopics with Existing Topic Name (Read __cluster_metadata)
- Handle attempts to create system topics (__cluster_metadata): INVALID_REQUEST (42)
- Handle duplicate topic creation attempts: TOPIC_ALREADY_EXISTS (36)

Stage CT4: CreateTopics with Validation Only
- Success case without persisting any data

Stage CT5: CreateTopics with Valid Parameters (Success Case)
- Successfully create single topic with valid parameters
- Core success functionality

Stage CT6: Multiple topics in single CreateTopics request
- Handle multiple topics in a single request
