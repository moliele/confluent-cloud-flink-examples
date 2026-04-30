locals {
  flink_compute_pool    = "${var.prefix}-${var.flink_compute_pool_name}"
}

data "confluent_flink_region" "main" {
  cloud  = var.cloud_provider
  region = var.cloud_region
}

resource "confluent_flink_compute_pool" "main" {
  display_name = local.flink_compute_pool
  cloud        = var.cloud_provider
  region       = var.cloud_region
  max_cfu      = var.flink_max_cfu

  environment {
    id = confluent_environment.env.id
  }

}