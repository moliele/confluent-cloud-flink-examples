############################
#  Cloud Credentials       #
############################

variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (control plane)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret (control plane)"
  type        = string
  sensitive   = true
}

#############
# Naming    #
#############

variable "prefix" {
  description = "Prefix set up in the variables provided"
  type        = string
  default     = "demo"
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "env"
}

#########################
# Cluster / Cloud / Reg #
#########################

variable "cloud_provider" {
  description = "Cloud service provider"
  type        = string
  default     = "AWS"

  validation {
    condition     = contains(["AWS", "GCP", "AZURE"], upper(var.cloud_provider))
    error_message = "cloud_provider should be one of: AWS, GCP, AZURE."
  }
}

variable "cloud_region" {
  description = "CSP Region to deploy the resources"
  type        = string
  default     = "eu-west-1"
}

variable "kafka_cluster_name" {
  type        = string
  description = "Name of the cluster"
  default     = "demo-kafka-cluster"
}

#########################
# Flink Compute Pool    #
#########################

variable "flink_max_cfu" {
  description = "Max CFUs for the Flunk Compute Pool"
  type        = number
  default     = 5
}

variable "flink_compute_pool_name" {
  type        = string
  description = "Name of Flink compute pool"
  default     = "demo-flink-compute-pool"
}

#########################
# Topic + Datagen       #
#########################

variable "datagen_topic_name" {
  description = "Name of the mixed topic (without prefix)"
  type        = string
  default     = "events"
}