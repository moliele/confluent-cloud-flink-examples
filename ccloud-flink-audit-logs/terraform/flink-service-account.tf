
# RBAC: FlinkDeveloper sobre el environment
/*resource "confluent_role_binding" "app_manager_flink_developer" {
  principal   = "User:${confluent_service_account.app_manager.id}"
  role_name   = "FlinkDeveloper"
  crn_pattern = confluent_environment.env.resource_name
}*/

resource "confluent_api_key" "app_manager_flink" {
  display_name = "${var.prefix}-app-manager-flink-api-key"
  description  = "Flink API key para app_manager"

  owner {
    id          = confluent_service_account.app_manager.id
    api_version = confluent_service_account.app_manager.api_version
    kind        = confluent_service_account.app_manager.kind
  }

  managed_resource {
    id          = data.confluent_flink_region.main.id
    api_version = data.confluent_flink_region.main.api_version
    kind        = data.confluent_flink_region.main.kind
    environment {
      id = confluent_environment.env.id
    }
  }
  depends_on = [
    confluent_role_binding.app_manager_env_admin,
  ]
}