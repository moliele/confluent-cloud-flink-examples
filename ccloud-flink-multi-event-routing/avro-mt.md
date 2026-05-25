# Routing with Avro using Materialized Tables (RecordNameStrategy)

This guide explains how to route mixed Avro events from the topic `<prefix>-events` into separate materialized outputs using Confluent Cloud Flink.

## 1. Access the Flink SQL Workspace

1.  In the Confluent Cloud UI, navigate to the **Environment** named `<prefix>-flink-env`.
2.  Click on **Compute pools** and select the pool created by Terraform.
3.  Click **Open Flink SQL workspace** or **Run SQL**.
4.  In the SQL editor, ensure the context is set to:
   * **Catalog**: `<prefix>-flink-env`
   * **Database**: `<prefix>-kafka-cluster`

## 2. Identify the Avro Subjects

Before adjusting the table, verify the exact subject names in Schema Registry:

1.  Navigate to **Schema Registry** → **Subjects**.
2.  Locate the subjects for `<prefix>-events`. They typically follow this pattern (the `ksql` portion is added by the Datagen connector):
   * `<prefix>-events-ksql.pageviews`
   * `<prefix>-events-ksql.users`

## 3. Adjust the Source Table Definition

Execute in the Flink editor the following `ALTER TABLE` statement to enable Flink to recognize both record types within the multi-event Avro topic.

**Note:** Ensure the subject names match those found in the previous step.

```sql
ALTER TABLE `<prefix>-events`
SET (
  'value.format' = 'avro-registry',
  'value.avro-registry.subject-names' = '<prefix>-events-ksql.pageviews;<prefix>-events-ksql.users'
);
```

To verify, run:

```sql
SELECT * FROM `<prefix>-events`;
```

You should see rows where either the `users` or `pageviews` columns contain data.

## 4. Create Materialized Tables

Create one Materialized Table for each routed event type. These Materialized Tables will maintain the filtered results as persistent derived outputs managed by Confluent Cloud Flink.

### 4.1 USERS Materialized Table
```sql
CREATE MATERIALIZED TABLE `<prefix>-users`
AS
SELECT
  users.registertime AS registertime,
  users.userid       AS userid,
  users.regionid     AS regionid,
  users.gender       AS gender
FROM `<prefix>-events`
WHERE users IS NOT NULL;
```

### 4.2 PAGEVIEWS Materialized Table
```sql
CREATE MATERIALIZED TABLE `<prefix>-pageviews`
AS
SELECT
  pageviews.viewtime AS viewtime,
  pageviews.userid   AS userid,
  pageviews.pageid   AS pageid
FROM `<prefix>-events`
WHERE pageviews IS NOT NULL;
```

## 5. Verify Routing Results

Check the Materialized Tables to confirm the data has been correctly separated:

```sql
SELECT * FROM `<prefix>-users`;
SELECT * FROM `<prefix>-pageviews`;
```

## 6. Evolve the Routing Logic

If you need to update the routing logic later, use `CREATE OR ALTER MATERIALIZED TABLE`. This allows the platform to handle the evolution of the underlying system statement without manually stopping and recreating `INSERT INTO` jobs.

For example, to evolve the `users` output:

```sql
CREATE OR ALTER MATERIALIZED TABLE `<prefix>-users`
START_MODE = RESUME_OR_FROM_BEGINNING
AS
SELECT
  users.registertime AS registertime,
  users.userid       AS userid,
  users.regionid     AS regionid,
  users.gender       AS gender
FROM `<prefix>-events`
WHERE users IS NOT NULL;
```

`START_MODE` controls how much historical data is processed when the Materialized Table is created or evolved. Useful values include:

* `FROM_BEGINNING`
* `FROM_NOW`
* `FROM_TIMESTAMP('...')`
* `RESUME_OR_FROM_BEGINNING`
* `RESUME_OR_FROM_NOW`


## Sources

- [CREATE MATERIALIZED TABLE Statement in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/reference/statements/create-materialized-table.html)
- [Flink SQL Statements in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/concepts/statements.html)
- [SQL Statements in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/reference/statements/overview.html)
