data "confluent_kafka_cluster" "audit_cluster" {
  id = var.source_audit_log_cluster_id

  environment {
    id = var.source_audit_log_environment_id
  }
}

resource "confluent_service_account" "cluster_linking_service_account" {
  count        = var.enabled ? 1 : 0
  display_name = "${var.prefix}-audit-logs-cl-sa"
  description  = "Service account to manage Audit Logs Cluster Linking"
}

resource "confluent_role_binding" "cluster_admin" {
  count       = var.enabled ? 1 : 0
  principal   = "User:${confluent_service_account.cluster_linking_service_account[0].id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = var.destination_kafka_cluster_rbac_crn
}

resource "confluent_role_binding" "environment_admin" {
  count       = var.enabled ? 1 : 0
  principal   = "User:${confluent_service_account.cluster_linking_service_account[0].id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = var.destination_environment_resource_name
}

resource "confluent_api_key" "destination_api_key" {
  count        = var.enabled ? 1 : 0
  display_name = "${var.prefix}-audit-logs-cl-dest-api-key"
  description  = "Kafka API key for Audit Logs Cluster Linking destination"

  owner {
    id          = confluent_service_account.cluster_linking_service_account[0].id
    api_version = confluent_service_account.cluster_linking_service_account[0].api_version
    kind        = confluent_service_account.cluster_linking_service_account[0].kind
  }

  managed_resource {
    id          = var.destination_kafka_cluster_id
    api_version = var.destination_kafka_cluster_api_version
    kind        = var.destination_kafka_cluster_kind

    environment {
      id = var.destination_environment_id
    }
  }

  depends_on = [
    confluent_role_binding.cluster_admin,
    confluent_role_binding.environment_admin
  ]
}

resource "confluent_cluster_link" "audit_logs" {
  count     = var.enabled ? 1 : 0
  link_name = "${var.prefix}-audit-logs-link"

  source_kafka_cluster {
    id                 = data.confluent_kafka_cluster.audit_cluster.id
    bootstrap_endpoint = data.confluent_kafka_cluster.audit_cluster.bootstrap_endpoint

    credentials {
      key    = var.source_audit_log_api_key
      secret = var.source_audit_log_api_secret
    }
  }

  destination_kafka_cluster {
    id            = var.destination_kafka_cluster_id
    rest_endpoint = var.destination_kafka_cluster_rest_endpoint

    credentials {
      key    = confluent_api_key.destination_api_key[0].id
      secret = confluent_api_key.destination_api_key[0].secret
    }
  }

  depends_on = [
    confluent_api_key.destination_api_key
  ]
}

resource "confluent_kafka_mirror_topic" "audit_logs_events" {
  count = var.enabled ? 1 : 0

  source_kafka_topic {
    topic_name = var.source_topic_name
  }

  cluster_link {
    link_name = confluent_cluster_link.audit_logs[0].link_name
  }

  kafka_cluster {
    id            = var.destination_kafka_cluster_id
    rest_endpoint = var.destination_kafka_cluster_rest_endpoint

    credentials {
      key    = confluent_api_key.destination_api_key[0].id
      secret = confluent_api_key.destination_api_key[0].secret
    }
  }

  depends_on = [
    confluent_cluster_link.audit_logs
  ]
}