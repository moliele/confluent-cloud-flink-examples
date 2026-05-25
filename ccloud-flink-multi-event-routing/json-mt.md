# Routing with Plain JSON using Materialized Tables

This guide routes mixed JSON events from `<prefix>-events-json` into separate outputs by using **Materialized Tables** in Confluent Cloud for Apache Flink.

Materialized Tables are persistent objects that combine a table definition with a continuous query. When you create one, Confluent Cloud creates the backing Kafka topic, registers the output schema in Schema Registry, and starts the continuous query that writes results into that topic.

## 1. Open the Flink SQL workspace

1. In Confluent Cloud, open the environment named `<prefix>-flink-env`.
2. Open the Flink SQL workspace for the compute pool created for this lab.
3. In the SQL editor, set the context to:
   - Catalog: `<prefix>-flink-env`
   - Database: `<prefix>-kafka-cluster`

In Confluent Cloud, Kafka topics are exposed as Flink tables, and creating a Flink table or materialized table creates the corresponding Kafka topic and schema resources behind the scenes.

## 2. Confirm the source shape

Terraform creates the source topic and supporting resources for this lab. In Flink, the auto-created table for `<prefix>-events-json` typically looks like this:

```sql
`<prefix>-events-json` (
  `key` BYTES,
  `val` STRING
)
```

Because the payload is plain JSON text, extract individual fields with `JSON_VALUE`.

## 3. Create Materialized Tables from the raw JSON source

Instead of creating sink tables and then maintaining separate `INSERT INTO` statements, define one Materialized Table per routed output.

This works well here because a Materialized Table is a single declarative object that owns both the output definition and the continuous query.

### 3.1 USERS output

```sql
CREATE MATERIALIZED TABLE `<prefix>-users-json`
WITH (
  'value.format' = 'json-registry'
)
AS
SELECT
  CAST(JSON_VALUE(CAST(val AS STRING), '$.registertime') AS BIGINT) AS registertime,
  JSON_VALUE(CAST(val AS STRING), '$.userid')                       AS userid,
  JSON_VALUE(CAST(val AS STRING), '$.regionid')                     AS regionid,
  JSON_VALUE(CAST(val AS STRING), '$.gender')                       AS gender
FROM `<prefix>-events-json`
WHERE JSON_VALUE(CAST(val AS STRING), '$.registertime') IS NOT NULL;
```

### 3.2 PAGEVIEWS output

```sql
CREATE MATERIALIZED TABLE `<prefix>-pageviews-json`
WITH (
  'value.format' = 'json-registry'
)
AS
SELECT
  CAST(JSON_VALUE(CAST(val AS STRING), '$.viewtime') AS BIGINT) AS viewtime,
  JSON_VALUE(CAST(val AS STRING), '$.userid')                  AS userid,
  JSON_VALUE(CAST(val AS STRING), '$.pageid')                  AS pageid
FROM `<prefix>-events-json`
WHERE JSON_VALUE(CAST(val AS STRING), '$.viewtime') IS NOT NULL;
```

Materialized Tables can use either an explicit schema or an inferred schema from the `SELECT` query, and they support `WITH` properties such as `value.format` for configuring the backing topic.

## 4. Verify the results

Query the outputs directly:

```sql
SELECT * FROM `<prefix>-users-json`;
SELECT * FROM `<prefix>-pageviews-json`;
```

## 5. Why use Materialized Tables here

Compared with a pattern based on `CREATE TABLE` plus long-running `INSERT INTO`, Materialized Tables give you a single persistent object for each routed output and a cleaner way to evolve the pipeline over time.

## 6. Evolve the routing logic later

To change the query later, use `CREATE OR ALTER MATERIALIZED TABLE`.

```sql
CREATE OR ALTER MATERIALIZED TABLE `<prefix>-users-json`
START_MODE = RESUME_OR_FROM_BEGINNING
WITH (
  'value.format' = 'json-registry'
)
AS
SELECT
  CAST(JSON_VALUE(CAST(val AS STRING), '$.registertime') AS BIGINT) AS registertime,
  JSON_VALUE(CAST(val AS STRING), '$.userid')                       AS userid,
  JSON_VALUE(CAST(val AS STRING), '$.regionid')                     AS regionid,
  JSON_VALUE(CAST(val AS STRING), '$.gender')                       AS gender
FROM `<prefix>-events-json`
WHERE JSON_VALUE(CAST(val AS STRING), '$.registertime') IS NOT NULL;
```

Materialized Tables are designed to support in-place evolution by using `CREATE OR ALTER MATERIALIZED TABLE`.

## 7. `START_MODE`

`START_MODE` controls how much historical data is processed when the Materialized Table is created. If omitted, the default is `RESUME_OR_FROM_BEGINNING`.

Useful values include:

- `FROM_BEGINNING`
- `FROM_NOW`
- `FROM_TIMESTAMP('...')`
- `RESUME_OR_FROM_BEGINNING`
- `RESUME_OR_FROM_NOW`

## 8. Important note

Materialized Tables can only be created as new tables. Existing tables cannot be converted into Materialized Tables.

## Sources

- [CREATE MATERIALIZED TABLE Statement in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/reference/statements/create-materialized-table.html)
- [Flink SQL Statements in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/concepts/statements.html)
- [SQL Statements in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/reference/statements/overview.html)

