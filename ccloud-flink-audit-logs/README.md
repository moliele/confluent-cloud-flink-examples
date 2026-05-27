# Confluent Cloud Flink: Multi-Event Routing with Audit Logs Cluster Link

### ⚠️ IMPORTANT: LAB DISCLAIMER
> **DISCLAIMER:** This repository and the configurations provided here are for **educational and lab purposes only**. This setup extends the existing Flink multi-event routing example with a **Cluster Link from Audit Logs** into a destination Kafka cluster. It is **not** production-ready. Before using this pattern in production, review security, RBAC, secret handling, networking, retention, and cost controls.

---

## 🚀 Overview

This lab automates a complete **Confluent Cloud** setup with **Terraform** for **Audit Logs ingestion via Cluster Linking**.

After mirroring the topic `confluent-audit-log-events`, **Apache Flink for Confluent Cloud** reads that mirrored topic and routes selected Audit Log events into different outputs.

### What this lab does

Terraform creates the **destination side** of the platform and the resources needed to process the data:

- Confluent **Environment**
- destination **Kafka cluster**
- **Flink compute pool**
- service accounts, RBAC, and API keys required by the lab
- the destination-side resources required to run the Audit Logs routing example in Flink
- a reusable Terraform module that creates an **Audit Logs Cluster Link**
- a mirror topic for `confluent-audit-log-events` in the destination cluster

### What is done manually

The **Audit Logs source API key and secret** need to be created **manually with the Confluent CLI** and then passed into Terraform as variables.

This is intentional: for Audit Logs, the source API key is typically created outside Terraform and tied to the Audit Logs cluster itself.

### End-to-end flow

1. Terraform creates the destination environment, Kafka cluster, Flink pool, service accounts, and the Cluster Link resources.
2. You manually create the **Audit Logs API key** with the Confluent CLI.
3. Terraform creates the **Cluster Link** from the Audit Logs cluster into the destination cluster.
4. Terraform creates the mirror topic `confluent-audit-log-events`.
5. After `terraform apply`, you open the **Flink workspace** in Confluent Cloud.
6. In the Flink workspace, you run SQL over the mirror topic and create routed outputs as `MATERIALIZED TABLES`, which create their backing topics automatically.

---

## Confluent Documentation

- [Handle Multiple Event Types with Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/how-to-guides/multiple-event-types.html#best-practices)
- [Confluent Cloud Audit Logs](https://docs.confluent.io/cloud/current/monitoring/audit-logging/audit-logging.html)
- [Cluster Linking in Confluent Cloud](https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/index.html)
- [Confluent CLI](https://docs.confluent.io/confluent-cli/current/overview.html)

---

## 🛠️ Prerequisites

- [Terraform](https://www.terraform.io/downloads)
- [Confluent CLI](https://docs.confluent.io/confluent-cli/current/install.html)
- A Confluent Cloud account
- A **Cloud API key** for Terraform management operations
- Audit Logs available in the organization
- Permissions to create:
  - environments
  - Kafka clusters
  - Flink compute pools
  - service accounts
  - role bindings
  - Kafka API keys
  - cluster links

> Note: the Audit Logs topic mirrored by this lab is `confluent-audit-log-events`.

---

## 📦 What Terraform Creates

This lab is intended to create everything needed on the **destination side**:

1. A Confluent **Environment**
2. A destination **Kafka cluster**
3. A **Flink compute pool**
4. Service accounts and RBAC for Flink and Cluster Linking
5. A destination Kafka API key for Cluster Linking
6. A **Cluster Link** that reads from Audit Logs
7. A mirror topic for `confluent-audit-log-events`

### Important boundary

Terraform does **not** create the Audit Logs cluster itself. That source cluster is managed by Confluent Cloud and must be referenced by its **environment ID** and **cluster ID**.

---

## 🔐 Step 1: Create the Confluent Cloud API Key

Create a **Cloud API key** for Terraform management operations.

In the Confluent Cloud UI:

1. Open your profile or organization menu
2. Go to **Account & access**
3. Create a **Cloud API key**
4. Save:
  - `confluent_cloud_api_key`
  - `confluent_cloud_api_secret`

These credentials are used by the Terraform provider.

Example:

```hcl
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}
```

---

## 🔍 Step 2: Get the Audit Logs IDs with Confluent CLI

Before Terraform can create the Cluster Link, you need the **Audit Logs environment ID** and **cluster ID**.

```bash
confluent login --prompt
confluent audit-log describe
```

When Audit Logs is available, this command gives you the Audit Logs:

- environment ID
- cluster ID
- service account ID used for the Audit Logs resource

> If `confluent audit-log describe` returns `audit logs are not enabled for this organization`, Audit Logs is not yet available in the active org context.

---

## 🔑 Step 3: Create the Audit Logs API Key Manually

The source API key for the Audit Logs cluster is created **manually** with the Confluent CLI.

### 3.1 Set the CLI context

```bash
confluent environment use <audit-log-environment-id>
confluent kafka cluster use <audit-log-cluster-id>
```

### 3.2 Create the API key

Use the **service account returned by `confluent audit-log describe`**.

```bash
confluent api-key create \
  --service-account <audit-log-service-account-id> \
  --resource <audit-log-cluster-id>
```

This is the important part for Audit Logs: create the key with the **Audit Logs service account** and the **Audit Logs cluster ID** as the resource.

> Important:
> - The secret is shown only at creation time, so store it securely.
> - Audit Logs API keys are tied to the Audit Logs cluster.

---

## 🧱 Step 4: Configure Terraform Variables

Copy the template and create your local variables file:

```bash
cp terraform.tfvars.template terraform.tfvars
```

Set the variables for:

- Cloud API key and secret
- destination naming prefix
- destination cloud and region
- Audit Logs environment and cluster IDs
- Audit Logs API key and secret

Also the Audit Logs details:

- `audit_log_environment_id`
- `audit_log_cluster_id`
- `audit_log_api_key`
- `audit_log_api_secret`

### Example `terraform.tfvars`

```hcl
prefix = "my-demo"

cloud_provider = "AWS"
cloud_region   = "eu-west-1"

enable_audit_logs = true

confluent_cloud_api_key    = "your-cloud-api-key"
confluent_cloud_api_secret = "your-cloud-api-secret"

audit_log_environment_id = "env-xxxxx"
audit_log_cluster_id     = "lkc-xxxxx"
audit_log_api_key        = "your-audit-log-api-key"
audit_log_api_secret     = "your-audit-log-api-secret"
```

### Variable meaning

- `prefix`: base name for the created resources
- `cloud_provider`: destination cloud provider
- `cloud_region`: destination region
- `enable_audit_logs`: enables the Cluster Link module
- `audit_log_environment_id`: Audit Logs environment ID discovered with CLI
- `audit_log_cluster_id`: Audit Logs cluster ID discovered with CLI
- `audit_log_api_key`: manually created Audit Logs API key
- `audit_log_api_secret`: manually created Audit Logs API secret

> The module uses a Terraform `data "confluent_kafka_cluster"` lookup to resolve the Audit Logs `bootstrap_endpoint`, so you do **not** need to provide that value manually.

### Better option for secrets

Use environment variables instead of storing secrets in files:

```bash
export TF_VAR_confluent_cloud_api_key="your-cloud-api-key"
export TF_VAR_confluent_cloud_api_secret="your-cloud-api-secret"

export TF_VAR_audit_log_environment_id="env-xxxxx"
export TF_VAR_audit_log_cluster_id="lkc-xxxxx"
export TF_VAR_audit_log_api_key="your-audit-log-api-key"
export TF_VAR_audit_log_api_secret="your-audit-log-api-secret"
```

---

## 🏗️ Step 5: Deploy the Infrastructure

Initialize and apply Terraform:

```bash
terraform init
terraform plan
terraform apply
```

Terraform is expected to create:

1. A destination Confluent **Environment**
2. A destination **Kafka cluster**
3. A **Flink compute pool**
4. Service accounts and RBAC
5. The **Audit Logs Cluster Link module**
6. A mirror topic for `confluent-audit-log-events`

Wait until `terraform apply` finishes successfully before moving to Flink.

---

## 🔀 Step 6: Open the Flink Workspace

After `terraform apply`, go to **Confluent Cloud** and open the **destination environment** created by Terraform.

### 6.1 Navigate to the Flink workspace

1. Open the **Environment** created by Terraform
2. Open the **Kafka cluster** created by Terraform
3. Open **Apache Flink**
4. Open the **SQL workspace** associated with the compute pool

### 6.2 Select the correct context in the workspace

Before running any SQL:

1. In the workspace, select the **catalog / database / context** that contains the mirror topic
2. Locate the inferred table for `confluent-audit-log-events`
3. Verify that the topic is visible from the Flink workspace before creating any Materialized Tables

The examples below assume you have already selected the correct context in the workspace, so the SQL uses the inferred table name directly:

- `confluent-audit-log-events`

That keeps the SQL cleaner and avoids hardcoding fully qualified names.

---

## 🧠 Step 7: Run the Audit Logs Flink Routing

Once you are inside the Flink workspace and the correct context is selected, the Flink source for this lab is the **mirror topic**:

- `confluent-audit-log-events`

This topic is consumed from the **destination cluster**.

### Goal

The routing flow reads the mirrored Audit Logs stream and creates dedicated outputs for operational analysis.

For this lab, the example outputs are:

- `<prefix>-audit-authz-denied`
- `<prefix>-audit-failures`
- `<prefix>-audit-kafka-fetch`

### Source format

In this case, the mirrored Audit Logs topic is treated as **raw bytes containing JSON**.

That means the Flink source reads the Kafka value as `val BYTES`, and the JSON payload is parsed from:

```sql
CAST(val AS STRING)
```

### Flink Processing

For this use case, the recommended pattern is:

1. use the inferred source table over `confluent-audit-log-events`
2. create one base `MATERIALIZED TABLE` that parses the JSON payload
3. create additional `MATERIALIZED TABLE`s for each routed output

### Example routing logic

Use a base parsed Materialized Table:

```sql
CREATE MATERIALIZED TABLE `audit-logs-parsed` AS
SELECT
  CAST(val AS STRING) AS payload, -- raw event as JSON string

  -- top-level event context
  JSON_VALUE(CAST(val AS STRING), '$.id') AS event_id, -- unique event ID
  JSON_VALUE(CAST(val AS STRING), '$.time') AS event_time, -- when the event happened
  JSON_VALUE(CAST(val AS STRING), '$.type') AS event_type, -- event category, for example authentication or authorization
  JSON_VALUE(CAST(val AS STRING), '$.source') AS source, -- context where the event happened, often the cluster CRN
  JSON_VALUE(CAST(val AS STRING), '$.subject') AS subject, -- resource affected by the event
  JSON_VALUE(CAST(val AS STRING), '$.specversion') AS specversion, -- CloudEvents spec version
  JSON_VALUE(CAST(val AS STRING), '$.datacontenttype') AS datacontenttype, -- payload format, usually application/json

  -- main data payload
  JSON_VALUE(CAST(val AS STRING), '$.data.serviceName') AS service_name, -- cluster or service where the event happened
  JSON_VALUE(CAST(val AS STRING), '$.data.methodName') AS method_name, -- operation being checked or executed
  JSON_VALUE(CAST(val AS STRING), '$.data.resourceName') AS resource_name, -- target resource, for example cluster, topic, or group

  -- authentication details
  JSON_VALUE(CAST(val AS STRING), '$.data.authenticationInfo.principal') AS principal, -- authenticated principal
  JSON_VALUE(CAST(val AS STRING), '$.data.authenticationInfo.identity') AS principal_identity, -- identity in CRN format when present
  JSON_VALUE(CAST(val AS STRING), '$.data.authenticationInfo.result') AS authentication_result,

  -- authorization details
  JSON_VALUE(CAST(val AS STRING), '$.data.authorizationInfo.granted') AS authorization_granted, -- whether authorization was allowed
  JSON_VALUE(CAST(val AS STRING), '$.data.authorizationInfo.operation') AS authorization_operation, -- authorized operation
  JSON_VALUE(CAST(val AS STRING), '$.data.authorizationInfo.resourceType') AS authorization_resource_type, -- type of resource, for example Topic or Cluster
  JSON_VALUE(CAST(val AS STRING), '$.data.authorizationInfo.resourceName') AS authorization_resource_name, -- logical resource name used in the check
  JSON_VALUE(CAST(val AS STRING), '$.data.authorizationInfo.result') AS authorization_result, -- logical resource name used in the check

  -- request details
  JSON_VALUE(CAST(val AS STRING), '$.data.request.correlationId') AS correlation_id, -- request correlation ID
  JSON_VALUE(CAST(val AS STRING), '$.data.request.clientId') AS client_id, -- client identifier

  -- result details
  JSON_VALUE(CAST(val AS STRING), '$.data.result.status') AS result_status, -- final status when present
  JSON_VALUE(CAST(val AS STRING), '$.data.result.data.errorCode') AS error_code, -- error code when failed
  JSON_VALUE(CAST(val AS STRING), '$.data.result.data.errorType') AS error_type -- error type when failed

FROM `confluent-audit-log-events`;
```

Then create routed outputs such as:

*Please replace the <lkc-xxxxxx> of the following query with the cluster id you want to capture the logs.*

```sql
CREATE MATERIALIZED TABLE `<prefix>-audit-cluster` AS
SELECT payload,
  event_id,
  event_time,
  event_type,
  source,
  subject,
  service_name,
  method_name,
  resource_name,
  principal,
  principal_identity,
  authentication_result,
  authorization_granted,
  authorization_operation,
  authorization_resource_type,
  authorization_resource_name,
  authorization_result,
  client_id,
  result_status,
  error_code,
  error_type
FROM `audit-logs-parsed`
WHERE service_name LIKE '%kafka=<lkc-xxxxxx>%'; -- cluster where the event happened
```

```sql
CREATE MATERIALIZED TABLE `<prefix>-audit-authz-denied` AS
SELECT
  event_time,
  method_name,
  principal_identity,
  resource_name,
  authorization_result
FROM `audit-logs-parsed`
WHERE authorization_result = 'DENY';
```

```sql
CREATE MATERIALIZED TABLE `<prefix>-audit-failures` AS
SELECT
  event_time,
  method_name,
  principal_identity,
  resource_name,
  result_status,
  error_code,
  error_type
FROM `audit-logs-parsed`
WHERE result_status <> 'SUCCESS';
```

```sql
CREATE MATERIALIZED TABLE `<prefix>-audit-kafka-fetch` AS
SELECT
  event_time,
  method_name,
  principal_identity,
  resource_name,
  client_id,
  result_status
FROM `audit-logs-parsed`
WHERE method_name = 'kafka.Fetch';
```

### (Optional) Evolve a Materialized Table later

If you need to change the routing logic later, use `CREATE OR ALTER MATERIALIZED TABLE`.

Example: add `client_id` to `<prefix>-audit-authz-denied`:

```sql
CREATE OR ALTER MATERIALIZED TABLE `<prefix>-audit-authz-denied`
START_MODE = RESUME_OR_FROM_BEGINNING
AS
SELECT
  event_time,
  method_name,
  principal_identity,
  resource_name,
  authorization_result,
  client_id
FROM `audit-logs-parsed`
WHERE authorization_result = 'DENY';
```

### What `START_MODE` means

`START_MODE` controls how much historical data is processed when the Materialized Table is created or evolved.

Useful values include:

- `FROM_BEGINNING`
- `FROM_NOW`
- `FROM_TIMESTAMP('...')`
- `RESUME_OR_FROM_BEGINNING`
- `RESUME_OR_FROM_NOW`

### What happens if you omit `START_MODE`

If you omit `START_MODE`, the default behavior is `RESUME_OR_FROM_BEGINNING`.

That means:

- if the Materialized Table already exists and you are evolving it, Flink tries to resume from the previous position
- if the Materialized Table does not exist yet, Flink starts from the beginning of the source

## ✅ Validation

Useful checks:

```bash
confluent kafka topic list
confluent kafka topic describe confluent-audit-log-events
```

And in Flink SQL:

```sql
SELECT * FROM `audit-logs-parsed` LIMIT 10;
SELECT * FROM `<prefix>-audit-authz-denied` LIMIT 10;
SELECT * FROM `<prefix>-audit-failures` LIMIT 10;
SELECT * FROM `<prefix>-audit-kafka-fetch` LIMIT 10;
```

---

## 🧹 Cleanup

To remove the Terraform-managed resources:

```bash
terraform destroy
```

This removes the destination-side resources managed by Terraform. If you created the Audit Logs source API key manually with the CLI, manage or delete it separately.

---
