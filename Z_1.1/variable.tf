variable "zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "token" {
  type        = string
  default     = ""
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "network_backet" {
  type        = string
  default     = "service"
  description = "VPC network&subnet name"
}

variable "default_location" {
  type        = string
  default     = "ru-central1"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "https://docs.amazonaws.cn/en_us/sagemaker/latest/dg-ecr-paths/ecr-eu-west-1.html"
}

variable "access_profile" {
  type        = string
  default     = "default"
  description = "https://docs.amazonaws.cn/en_us/cli/latest/userguide/cli-configure-files.html"
}