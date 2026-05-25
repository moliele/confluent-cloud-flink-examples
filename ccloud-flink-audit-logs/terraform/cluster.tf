locals {
  kafka_cluster_name    =  "${var.prefix}-${var.kafka_cluster_name}"
}

resource "confluent_kafka_cluster" "kafka_cluster" {
  display_name = local.kafka_cluster_name
  availability = "SINGLE_ZONE"
  cloud        = var.cloud_provider
  region       = var.cloud_region

  dedicated {
    cku = 1
  }

  environment {
    id = confluent_environment.env.id
  }
}
