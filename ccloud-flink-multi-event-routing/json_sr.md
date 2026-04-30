# Routing with JSON Schema Registry (JSON_SR)

This guide explains how to route mixed events from the topic `<prefix>-events-json-sr` using **JSON with Schema Registry** support.

When using `JSON_SR`, Confluent Cloud uses Schema Registry to validate and manage the structure of your JSON messages. Terraform has already configured the connectors to use the `TopicRecordNameStrategy`, resulting in multiple subjects for the same topic.

## 1. Identify the subjects in Schema Registry
Once the infrastructure is deployed, check **Schema Registry → Subjects** in the UI. You should see:
* `<prefix>-events-json-sr-ksql.pageviews`
* `<prefix>-events-json-sr-ksql.users`

## 2. Adjust the Flink Table Definition
By default, Flink might see the value as raw bytes. Execute the following statement to enable multi-schema support:

```sql
ALTER TABLE `<prefix>-events-json-sr`
SET (
  'value.format' = 'json-registry',
  'value.json-registry.subject-names' = '<prefix>-events-json-sr-ksql.pageviews;<prefix>-events-json-sr-ksql.users'
);
```

After the `ALTER` statement, Flink organizes the table by creating a **ROW** for each schema found in the registry:
* `ksql.pageviews`: Contains `viewtime`, `userid`, `pageid`.
* `ksql.users`: Contains `registertime`, `userid`, `regionid`, `gender`.

## 3. Create JSON_SR Sink Tables
Create the destination tables for the filtered data. These will also use the `json-registry` format.

### 3.1 USERS JSON_SR Sink
```sql
CREATE TABLE `<prefix>-users-json-sr` (
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

### 3.2 PAGEVIEWS JSON_SR Sink
```sql
CREATE TABLE `<prefix>-pageviews-json-sr` (
  viewtime BIGINT,
  userid   STRING,
  pageid   STRING
)
WITH (
  'connector'    = 'confluent',
  'value.format' = 'json-registry'
);
```

## 4. Route Data using Row Accessors
Because the schemas are mapped to rows, we access the fields using dot notation and filter by checking if the row `IS NOT NULL`.

### 4.1 Route USERS
```sql
INSERT INTO `<prefix>-users-json-sr`
SELECT
  `ksql.users`.registertime,
  `ksql.users`.userid,
  `ksql.users`.regionid,
  `ksql.users`.gender
FROM `<prefix>-events-json-sr`
WHERE `ksql.users` IS NOT NULL;
```

### 4.2 Route PAGEVIEWS
```sql
INSERT INTO `<prefix>-pageviews-json-sr`
SELECT
  `ksql.pageviews`.viewtime,
  `ksql.pageviews`.userid,
  `ksql.pageviews`.pageid
FROM `<prefix>-events-json-sr`
WHERE `ksql.pageviews` IS NOT NULL;
```

## 5. Verification
Verify the routing by querying the separate sink topics:
```sql
SELECT * FROM `<prefix>-users-json-sr`;
SELECT * FROM `<prefix>-pageviews-json-sr`;
```