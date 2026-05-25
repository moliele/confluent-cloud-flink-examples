# Service account "manager" para gestionar el cluster
resource "confluent_service_account" "app_manager" {
  display_name = "${var.prefix}-app-manager"
  description  = "Service account para gestionar el cluster Kafka"
}


# RBAC: CloudClusterAdmin sobre el cluster Kafka
resource "confluent_role_binding" "app_manager_kafka_cluster_admin" {
  principal   = "User:${confluent_service_account.app_manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.kafka_cluster.rbac_crn
}

# RBAC (Kafka, Flink, SR)
resource "confluent_role_binding" "app_manager_env_admin" {
  principal   = "User:${confluent_service_account.app_manager.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.env.resource_name
}


# Kafka Cluster API key  app_manager
resource "confluent_api_key" "app_manager_kafka" {
  display_name = "${var.prefix}-app-manager-kafka-api-key"
  description  = "Kafka API key para app_manager sobre el cluster"

  owner {
    id          = confluent_service_account.app_manager.id
    api_version = confluent_service_account.app_manager.api_version
    kind        = confluent_service_account.app_manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.kafka_cluster.id
    api_version = confluent_kafka_cluster.kafka_cluster.api_version
    kind        = confluent_kafka_cluster.kafka_cluster.kind
    environment {
      id = confluent_environment.env.id
    }
  }

  depends_on = [
    confluent_role_binding.app_manager_kafka_cluster_admin,
  ]
}