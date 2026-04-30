# Routing with Avro (RecordNameStrategy)

This guide explains how to route mixed Avro events from the topic `<prefix>-events` into separate sinks using Confluent Cloud Flink.

## 1. Access the Flink SQL Workspace

1.  In the Confluent Cloud UI, navigate to the **Environment** named `<prefix>-flink-env`.
2.  Click on **Compute pools** and select the pool created by Terraform.
3.  Click **Open Flink SQL workspace** or **Run SQL**.
4.  In the SQL editor, ensure the context is set to:
    * **Catalog**: `<prefix>-flink-env`
    * **Database**: `<prefix>-kafka-cluster`

## 2. Identify the Avro Subjects

Before adjusting the table, you must verify the exact subject names in Schema Registry:

1.  Navigate to **Schema Registry** → **Subjects**.
2.  Locate the subjects for `<prefix>-events`. They typically follow this pattern (the `ksql` portion is added by the Datagen connector):
    * `<prefix>-events-ksql.pageviews`
    * `<prefix>-events-ksql.users`

## 3. Adjust the Source Table Definition

Execute in the Fink editor the following `ALTER TABLE` statement to enable Flink to recognize both record types within the multi-event Avro topic. **Note:** Ensure the subject names match those found in the previous step.

```sql
ALTER TABLE `<prefix>-events`
SET (
  'value.format' = 'avro-registry',
  'value.avro-registry.subject-names' = '<prefix>-events-ksql.pageviews;<prefix>-events-ksql.users'
);
```

To verify, run `SELECT * FROM <prefix>-events;`. You should see rows where either the `User` or `Pageview` columns contain data.

## 4. Create Avro Sink Tables

Create the target tables that will receive the filtered events. These tables will write to separate Kafka topics using the `avro-registry` format.

### 4.1 USERS Sink Table
```sql
CREATE TABLE `<prefix>-users` (
  registertime BIGINT,
  userid       STRING,
  regionid     STRING,
  gender       STRING
)
WITH (
  'connector'    = 'confluent',
  'value.format' = 'avro-registry'
);
```

### 4.2 PAGEVIEWS Sink Table
```sql
CREATE TABLE `<prefix>-pageviews` (
  viewtime BIGINT,
  userid   STRING,
  pageid   STRING
)
WITH (
  'connector'    = 'confluent',
  'value.format' = 'avro-registry'
);
```

## 5. Route the Event Types

Run these continuous `INSERT` statements to split the mixed stream into the dedicated sink tables.

### 5.1 Route USERS
```sql
INSERT INTO `<prefix>-users`
SELECT
  users.registertime,
  users.userid,
  users.regionid,
  users.gender
FROM `<prefix>-events`
WHERE users IS NOT NULL;
```

### 5.2 Route PAGEVIEWS
```sql
INSERT INTO `<prefix>-pageviews`
SELECT
  pageviews.viewtime,
  pageviews.userid,
  pageviews.pageid
FROM `<prefix>-events`
WHERE pageviews IS NOT NULL;
```

## 6. Verify Routing Results

Check the destination tables to confirm the data has been correctly separated:

```sql
SELECT * FROM `<prefix>-users`;
SELECT * FROM `<prefix>-pageviews`;
```
