output "cluster_link_name" {
  value = var.enabled ? confluent_cluster_link.audit_logs[0].link_name : null
}

output "destination_service_account_id" {
  value = var.enabled ? confluent_service_account.cluster_linking_service_account[0].id : null
}

output "destination_api_key_id" {
  value = var.enabled ? confluent_api_key.destination_api_key[0].id : null
}