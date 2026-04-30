# Routing with Plain JSON

This guide explains how to route mixed JSON events (without Schema Registry) from the topic `<prefix>-events-json` into separate sinks using Confluent Cloud Flink.

Terraform has already created the source topic and the connectors required for this lab. In Flink, the auto-created table for this topic typically treats the payload as a raw string:

```sql
`<prefix>-events-json` (
  `key` BYTES,
  `val` STRING   -- JSON payload as text
)
```

## 1. Create a Typed VIEW over the JSON
Since the data is plain text, we use a **VIEW** and the `JSON_VALUE` function to parse the fields and assign them correct data types.

```sql
CREATE VIEW `<prefix>-events-json-parsed` AS
SELECT
  CAST(JSON_VALUE(CAST(val AS STRING), '$.registertime') AS BIGINT) AS registertime,
  CAST(JSON_VALUE(CAST(val AS STRING), '$.viewtime')     AS BIGINT) AS viewtime,
  JSON_VALUE(CAST(val AS STRING), '$.userid')                      AS userid,
  JSON_VALUE(CAST(val AS STRING), '$.regionid')                    AS regionid,
  JSON_VALUE(CAST(val AS STRING), '$.gender')                      AS gender,
  JSON_VALUE(CAST(val AS STRING), '$.pageid')                      AS pageid
FROM `<prefix>-events-json`;
```

* **USERS events**: `registertime`, `regionid`, and `gender` will contain values while others are NULL.
* **PAGEVIEWS events**: `viewtime` and `pageid` will contain values while others are NULL.

## 2. Create JSON Sink Tables
Now, create the destination tables. Even though the source is plain JSON, these sinks are configured to use `json-registry` for better schema management in the output topics.

### 2.1 USERS JSON Sink
```sql
CREATE TABLE `<prefix>-users-json` (
  registertime BIGINT,
  userid       STRING,
  regionid     STRING,
  gender       STRING
)
WITH (
  'connector'    = 'confluent',
  'value.format' = 'json-registry'
);
```

### 2.2 PAGEVIEWS JSON Sink
```sql
CREATE TABLE `<prefix>-pageviews-json` (
  viewtime BIGINT,
  userid   STRING,
  pageid   STRING
)
WITH (
  'connector'    = 'confluent',
  'value.format' = 'json-registry'
);
```

## 3. Route Data from the Parsed VIEW
Finally, execute the continuous `INSERT` statements using `WHERE` clauses to filter by the presence of specific fields.

### 3.1 Route USERS
```sql
INSERT INTO `<prefix>-users-json`
SELECT
  registertime,
  userid,
  regionid,
  gender
FROM `<prefix>-events-json-parsed`
WHERE registertime IS NOT NULL;
```

### 3.2 Route PAGEVIEWS
```sql
INSERT INTO `<prefix>-pageviews-json`
SELECT
  viewtime,
  userid,
  pageid
FROM `<prefix>-events-json-parsed`
WHERE viewtime IS NOT NULL;
```

## 4. Verification
Verify that the records have been correctly separated by querying the sink tables:

```sql
SELECT * FROM `<prefix>-users-json`;
SELECT * FROM `<prefix>-pageviews-json`;
```