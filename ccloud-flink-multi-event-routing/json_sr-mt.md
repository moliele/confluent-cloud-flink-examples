# Routing with JSON Schema Registry using Materialized Tables (JSON_SR)

This guide explains how to route mixed JSON Schema Registry events from the topic `<prefix>-events-json-sr` into separate materialized outputs using Confluent Cloud for Apache Flink.

Materialized Tables are persistent objects that combine a table definition with a continuous query. When you create one, Confluent Cloud creates the backing Kafka topic, registers the output schema in Schema Registry, and starts the continuous query that writes results into that topic.

## 1. Identify the subjects in Schema Registry

Once the infrastructure is deployed, check **Schema Registry** → **Subjects** in the Confluent Cloud UI.

You should see subjects like:

* `<prefix>-events-json-sr-ksql.pageviews`
* `<prefix>-events-json-sr-ksql.users`

For topics using `RecordNameStrategy` or `TopicRecordNameStrategy`, Flink initially infers a raw binary table, so you need to configure the table with the appropriate subject names explicitly.

## 2. Adjust the Flink Table Definition

Execute the following statement in the Flink SQL editor to enable multi-schema support for the source topic:

```sql
ALTER TABLE `<prefix>-events-json-sr`
SET (
  'value.format' = 'json-registry',
  'value.json-registry.subject-names' = '<prefix>-events-json-sr-ksql.pageviews;<prefix>-events-json-sr-ksql.users'
);
```

When using alternative subject name strategies, Confluent documents this pattern of manually setting the schema format and subject names so Flink can resolve the event types correctly.

After the `ALTER`, Flink organizes the table by exposing one structure per event type. In this example:

* `ksql.pageviews` contains `viewtime`, `userid`, `pageid`
* `ksql.users` contains `registertime`, `userid`, `regionid`, `gender`

Confluent documents this general pattern for handling multiple event types in a single table and querying each event type with standard SQL.

## 3. Create Materialized Tables for Routing

Create one Materialized Table for each routed output.

Unlike a regular `CREATE TABLE` combined with `INSERT INTO`, a Materialized Table is a single declarative object that owns both the table definition and the continuous query.

### 3.1 USERS JSON_SR Output

```sql
CREATE MATERIALIZED TABLE `<prefix>-users-json-sr`
WITH (
  'value.format' = 'json-registry'
)
AS
SELECT
  `ksql.users`.registertime AS registertime,
  `ksql.users`.userid       AS userid,
  `ksql.users`.regionid     AS regionid,
  `ksql.users`.gender       AS gender
FROM `<prefix>-events-json-sr`
WHERE `ksql.users` IS NOT NULL;
```

### 3.2 PAGEVIEWS JSON_SR Output

```sql
CREATE MATERIALIZED TABLE `<prefix>-pageviews-json-sr`
WITH (
  'value.format' = 'json-registry'
)
AS
SELECT
  `ksql.pageviews`.viewtime AS viewtime,
  `ksql.pageviews`.userid   AS userid,
  `ksql.pageviews`.pageid   AS pageid
FROM `<prefix>-events-json-sr`
WHERE `ksql.pageviews` IS NOT NULL;
```

Materialized Tables support both explicit schemas and inferred schemas from the `SELECT` query, and they support `WITH` options such as `value.format` for configuring the backing topic.

## 4. Verify the Routing

Query the outputs directly:

```sql
SELECT * FROM `<prefix>-users-json-sr`;
SELECT * FROM `<prefix>-pageviews-json-sr`;
```

## 5. Evolve the Routing Logic

If you need to change the query later, use `CREATE OR ALTER MATERIALIZED TABLE`.

```sql
CREATE OR ALTER MATERIALIZED TABLE `<prefix>-users-json-sr`
START_MODE = RESUME_OR_FROM_BEGINNING
WITH (
  'value.format' = 'json-registry'
)
AS
SELECT
  `ksql.users`.registertime AS registertime,
  `ksql.users`.userid       AS userid,
  `ksql.users`.regionid     AS regionid,
  `ksql.users`.gender       AS gender
FROM `<prefix>-events-json-sr`
WHERE `ksql.users` IS NOT NULL;
```

Materialized Tables can be evolved in place by using `CREATE OR ALTER MATERIALIZED TABLE`.

## 6. `START_MODE`

`START_MODE` controls how much historical data is processed when the Materialized Table is created. If omitted, the default is `RESUME_OR_FROM_BEGINNING`.

Useful values include:

* `FROM_BEGINNING`
* `FROM_NOW`
* `FROM_TIMESTAMP('...')`
* `RESUME_OR_FROM_BEGINNING`
* `RESUME_OR_FROM_NOW`

## 7. Important Note

Materialized Tables can only be created as new tables. Existing tables cannot be converted into Materialized Tables.

## Sources

- [CREATE MATERIALIZED TABLE Statement in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/reference/statements/create-materialized-table.html)
- [Flink SQL Statements in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/concepts/statements.html)
- [SQL Statements in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/reference/statements/overview.html)

