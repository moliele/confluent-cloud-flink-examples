############################
#  Cloud Credentials       #
############################

variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (control plane)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret (control plane)"
  type        = string
  sensitive   = true
}

variable "enabled" {
  description = "Enable audit logs cluster linking"
  type        = bool
  default     = true
}

variable "prefix" {
  description = "Prefix for created resources"
  type        = string
}

variable "destination_environment_id" {
  description = "Destination environment ID"
  type        = string
}

variable "destination_environment_resource_name" {
  description = "Destination environment resource_name"
  type        = string
}

variable "destination_kafka_cluster_id" {
  description = "Destination Kafka cluster ID"
  type        = string
}

variable "destination_kafka_cluster_api_version" {
  description = "Destination Kafka cluster api_version"
  type        = string
}

variable "destination_kafka_cluster_kind" {
  description = "Destination Kafka cluster kind"
  type        = string
}

variable "destination_kafka_cluster_rest_endpoint" {
  description = "Destination Kafka cluster REST endpoint"
  type        = string
}

variable "destination_kafka_cluster_rbac_crn" {
  description = "Destination Kafka cluster RBAC CRN"
  type        = string
}

variable "source_audit_log_environment_id" {
  description = "Audit Logs source environment ID"
  type        = string
}

variable "source_audit_log_cluster_id" {
  description = "Audit Logs source cluster ID"
  type        = string
}

variable "source_audit_log_api_key" {
  description = "Audit Logs source API key"
  type        = string
  sensitive   = true
}

variable "source_audit_log_api_secret" {
  description = "Audit Logs source API secret"
  type        = string
  sensitive   = true
}

variable "source_topic_name" {
  description = "Audit Logs topic to mirror"
  type        = string
  default     = "confluent-audit-log-events"
}
