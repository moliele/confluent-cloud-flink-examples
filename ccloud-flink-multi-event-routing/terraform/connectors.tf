locals {
  datagen_users_name_avro = "${var.prefix}-datagen-users-avro"
  datagen_pv_name_avro   = "${var.prefix}-datagen-pageviews-avro"

  datagen_users_name_json = "${var.prefix}-datagen-users-json"
  datagen_pv_name_json   = "${var.prefix}-datagen-pageviews-json"


  datagen_users_name_json_sr = "${var.prefix}-datagen-users-json-sr"
  datagen_pv_name_json_sr   = "${var.prefix}-datagen-pageviews-json-sr"
}

#AVRO
resource "confluent_connector" "datagen_users" {
  environment {
    id = confluent_environment.env.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = local.datagen_users_name_avro
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.datagen_sa.id
    "kafka.topic"              = confluent_kafka_topic.mixed_events.topic_name
    "output.data.format"       = "AVRO"
    "quickstart"               = "USERS"
    "tasks.max"                = "1"
    "value.converter.value.subject.name.strategy" = "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy"

  }

  depends_on = [
    confluent_kafka_topic.mixed_events,
    confluent_kafka_acl.datagen_describe_cluster,
    confluent_kafka_acl.datagen_write_topics_with_prefix,
  ]
}

resource "confluent_connector" "datagen_pageviews" {
  environment {
    id = confluent_environment.env.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = local.datagen_pv_name_avro
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.datagen_sa.id
    "kafka.topic"              = confluent_kafka_topic.mixed_events.topic_name
    "output.data.format"       = "AVRO"
    "quickstart"               = "PAGEVIEWS"
    "tasks.max"                = "1"
    "value.converter.value.subject.name.strategy" = "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy"

  }

  depends_on = [
    confluent_kafka_topic.mixed_events,
    confluent_kafka_acl.datagen_describe_cluster,
    confluent_kafka_acl.datagen_write_topics_with_prefix,
  ]
}


#JSON
resource "confluent_connector" "datagen_users_json" {
  environment {
    id = confluent_environment.env.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = local.datagen_users_name_json
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.datagen_sa.id
    "kafka.topic"              = confluent_kafka_topic.mixed_events_json.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "USERS"
    "tasks.max"                = "1"
    "value.converter.value.subject.name.strategy" = "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy"

  }

  depends_on = [
    confluent_kafka_topic.mixed_events_json,
    confluent_kafka_acl.datagen_describe_cluster,
    confluent_kafka_acl.datagen_write_topics_with_prefix,
  ]
}

resource "confluent_connector" "datagen_pageviews_json" {
  environment {
    id = confluent_environment.env.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = local.datagen_pv_name_json
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.datagen_sa.id
    "kafka.topic"              = confluent_kafka_topic.mixed_events_json.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "PAGEVIEWS"
    "tasks.max"                = "1"
    "value.converter.value.subject.name.strategy" = "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy"

  }

  depends_on = [
    confluent_kafka_topic.mixed_events_json,
    confluent_kafka_acl.datagen_describe_cluster,
    confluent_kafka_acl.datagen_write_topics_with_prefix,
  ]
}

#JSON_SR
resource "confluent_connector" "datagen_users_json_sr" {
  environment {
    id = confluent_environment.env.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = local.datagen_users_name_json_sr
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.datagen_sa.id
    "kafka.topic"              = confluent_kafka_topic.mixed_events_json_sr.topic_name
    "output.data.format"       = "JSON_SR"
    "quickstart"               = "USERS"
    "tasks.max"                = "1"
    "value.converter.value.subject.name.strategy" = "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy"

  }

  depends_on = [
    confluent_kafka_topic.mixed_events_json_sr,
    confluent_kafka_acl.datagen_describe_cluster,
    confluent_kafka_acl.datagen_write_topics_with_prefix,
  ]
}

resource "confluent_connector" "datagen_pageviews_json_sr" {
  environment {
    id = confluent_environment.env.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = local.datagen_pv_name_json_sr
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.datagen_sa.id
    "kafka.topic"              = confluent_kafka_topic.mixed_events_json_sr.topic_name
    "output.data.format"       = "JSON_SR"
    "quickstart"               = "PAGEVIEWS"
    "tasks.max"                = "1"
    "value.converter.value.subject.name.strategy" = "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy"

  }

  depends_on = [
    confluent_kafka_topic.mixed_events_json_sr,
    confluent_kafka_acl.datagen_describe_cluster,
    confluent_kafka_acl.datagen_write_topics_with_prefix,
  ]
}