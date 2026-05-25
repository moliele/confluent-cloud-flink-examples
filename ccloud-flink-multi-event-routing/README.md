# Confluent Cloud Flink: Multi-Event Routing Lab with Terraform

### ⚠️ IMPORTANT: PRODUCTION DISCLAIMER
> **DISCLAIMER:** This repository and the configurations provided here are for **educational and laboratory purposes only**. This is a simplified example designed to demonstrate Flink SQL routing and Terraform automation. It is **not** production-ready. Ensure robust security auditing and cost management before any production deployment.

---

## 🚀 Overview
This project automates the deployment of a complete **Apache Flink** environment on **Confluent Cloud** using Terraform. It demonstrates how to handle "mixed topics" (topics containing multiple event types) and route them into specific sinks using Flink SQL.

**Key Features:**
* **Infrastructure as Code (IaC):** Full deployment of Environments, Kafka Clusters, and Flink Compute Pools.
* **Multi-Format Support:** Examples for **Avro**, **JSON**, and **JSON_SR** (JSON with Schema Registry).
* **Intelligent Routing:** Uses Flink SQL to parse and split mixed event streams (USERS and PAGEVIEWS) into dedicated topics.
* **Security:** Automated creation of Service Accounts and API Keys with appropriate RBAC roles (e.g., FlinkDeveloper).

---
## Confluent Documentation about the use case
* [Handle Multiple Event Types with Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/how-to-guides/multiple-event-types.html#best-practices)
---

## 🛠️ Prerequisites
* [Terraform](https://www.terraform.io/downloads) 
* Confluent Cloud Account with **Stream Governance** enabled.
* Confluent Cloud [Cloud API Key](https://docs.confluent.io/cloud/current/access-management/api-keys/api-keys.html#create-a-cloud-api-key) (Management key).

---

## 🏗️ Step 1: Environment Setup

1. Create the Confluent Cloud API key and secret
   In the Confluent Cloud UI:
    - Click your **profile/org** menu (top right) → **Account & access** (or **Access API keys**, depending on the UI).
    - Click **Create API key**.
    - Choose a **Cloud API key** (global / management), **not** a Kafka cluster API key.
    - Assign it to your user (or to a service account with the right permissions).
    - Copy and use them in the next step variables:
      - **API Key** → Use as `confluent_cloud_api_key`.
      - **API Secret** → Use as `confluent_cloud_api_secret`.
2. **Prepare Variables:**
    Copy the template and fill in your credentials:
    ```bash
    cp terraform.tfvars.template terraform.tfvars
    ```
3. **Configure `terraform.tfvars`:**
    Set the variables listed there like in the example below:
    ```hcl
    prefix = "my-demo"
    cloud_provider = "AWS"
    cloud_region = "eu-west-1"
    ```

---

## 🚀 Step 2: Infrastructure Deployment

Initialize and apply the Terraform plan:
```bash
terraform init
terraform plan
terraform apply
```

**Terraform will create:**
1. A Confluent Environment and Kafka Cluster.
2. A **Flink Compute Pool**.
3. Three mixed-event topics: `<prefix>-events` (Avro), `<prefix>-events-json`, and `<prefix>-events-json-sr`.
4. Six Datagen connectors: One for pageviews data and another one for users data per each record type (AVRO, JSON, JSON_SR).
5. Service accounts and ACLS.

---
## Step 3: Choose your format for routing

Once the infrastructure is deployed, follow the specific guide for the data format you wish to test:

1. [Avro Routing Guide](avro.md)
   - [Avro Routing Guide - using Materialized tables](avro-mt.md)
2. [JSON Routing Guide](json.md)
   - [JSON Routing Guide - using Materialized tables](json.md)
3. [JSON Schema Registry Guide](json_sr-mt.md)
   - [JSON Schema Registry Guide - using Materialized tables](json_st-mv.md)

## 🧹 Cleanup
To avoid ongoing costs for the Kafka cluster and Flink Compute Pool:
```bash
terraform destroy
```
