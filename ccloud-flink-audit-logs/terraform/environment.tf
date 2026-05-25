locals {
  env_name              = "${var.prefix}-${var.environment_name}"
}
resource "confluent_environment" "env" {
  display_name = local.env_name
}
