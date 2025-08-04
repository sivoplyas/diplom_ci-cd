terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.8.4"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

provider "aws" {
  region                   = var.default_aws_region
  profile                  = var.access_profile
  shared_credentials_files = ["./aws/credentials.empty"]
  shared_config_files      = ["./aws/config.empty"]
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key = yandex_iam_service_account_static_access_key.ssa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.ssa-static-key.secret_key
  endpoints {
    dynamodb = yandex_ydb_database_serverless.ssa-diplom.document_api_endpoint
  }
}