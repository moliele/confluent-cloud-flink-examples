resource "confluent_service_account" "datagen_sa" {
  display_name = "${var.prefix}-datagen-sa"
  description  = "Service account para Datagen (USERS y PAGEVIEWS)"
}

# ACL: DESCRIBE en el cluster
resource "confluent_kafka_acl" "datagen_describe_cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.datagen_sa.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"

  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
}

resource "confluent_kafka_acl" "datagen_create_topics_with_prefix" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  resource_type = "TOPIC"
  resource_name = "${var.prefix}-"
  pattern_type  = "PREFIXED"

  principal  = "User:${confluent_service_account.datagen_sa.id}"
  host       = "*"
  operation  = "CREATE"
  permission = "ALLOW"

  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
}

resource "confluent_kafka_acl" "datagen_write_topics_with_prefix" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  resource_type = "TOPIC"
  resource_name = "${var.prefix}-"
  pattern_type  = "PREFIXED"

  principal  = "User:${confluent_service_account.datagen_sa.id}"
  host       = "*"
  operation  = "WRITE"
  permission = "ALLOW"

  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
}

/*
resource "confluent_kafka_acl" "datagen_write_mixed_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.mixed_events.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.datagen_sa.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"

  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
}

resource "confluent_kafka_acl" "datagen_create_mixed_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.mixed_events.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.datagen_sa.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"

  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
}


resource "confluent_kafka_acl" "datagen_write_mixed_json_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.mixed_events_json.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.datagen_sa.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"

  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
}

resource "confluent_kafka_acl" "datagen_create_mixed_json_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.mixed_events_json.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.datagen_sa.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"

  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
}
*/