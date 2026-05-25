terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.69.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

data "confluent_organization" "main" {}

module "audit_logs_cluster_link" {
  source = "./modules/audit-logs-cluster-link"

  confluent_cloud_api_key    = var.confluent_cloud_api_key
  confluent_cloud_api_secret = var.confluent_cloud_api_secret

  enabled = var.enabled
  prefix  = var.prefix

  destination_environment_id            = confluent_environment.env.id
  destination_environment_resource_name = confluent_environment.env.resource_name

  destination_kafka_cluster_id            = confluent_kafka_cluster.kafka_cluster.id
  destination_kafka_cluster_api_version   = confluent_kafka_cluster.kafka_cluster.api_version
  destination_kafka_cluster_kind          = confluent_kafka_cluster.kafka_cluster.kind
  destination_kafka_cluster_rest_endpoint = confluent_kafka_cluster.kafka_cluster.rest_endpoint
  destination_kafka_cluster_rbac_crn      = confluent_kafka_cluster.kafka_cluster.rbac_crn

  source_audit_log_environment_id = var.audit_log_environment_id
  source_audit_log_cluster_id     = var.audit_log_cluster_id
  source_audit_log_api_key        = var.audit_log_api_key
  source_audit_log_api_secret     = var.audit_log_api_secret

  source_topic_name = var.topic_name
}
