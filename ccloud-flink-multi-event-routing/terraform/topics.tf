locals {
  mixed_topic_name   = "${var.prefix}-${var.datagen_topic_name}"
  mixed_topic_name_json   = "${var.prefix}-${var.datagen_topic_name}-json"
  mixed_topic_name_json_sr   = "${var.prefix}-${var.datagen_topic_name}-json-sr"
}

#AVRO
resource "confluent_kafka_topic" "mixed_events" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  topic_name    = local.mixed_topic_name
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint

  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
  #config = {
    #"confluent.value.subject.name.strategy" = "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy"
  #}
}

#JSON
resource "confluent_kafka_topic" "mixed_events_json" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  topic_name    = local.mixed_topic_name_json
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint

  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
  #config = {
  #"confluent.value.subject.name.strategy" = "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy"
  #}
}

#JSON_SR
resource "confluent_kafka_topic" "mixed_events_json_sr" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  topic_name    = local.mixed_topic_name_json_sr
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint

  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
  #config = {
  #"confluent.value.subject.name.strategy" = "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy"
  #}
}
/*
resource "confluent_kafka_topic" "users" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  topic_name    = "${var.prefix}-users"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint

  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
}

resource "confluent_kafka_topic" "pageviews" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  topic_name    = "${var.prefix}-pageviews"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint

  credentials {
    key    = confluent_api_key.app_manager_kafka.id
    secret = confluent_api_key.app_manager_kafka.secret
  }
}
*/