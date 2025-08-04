terraform {
  backend "s3" {
    region                   = "ru-central1"
#    profile                  = "default"
    bucket                   = "ssa-bucket"
    key                      = "diplom.tfstate"
    shared_credentials_files = ["s3.config"]
    endpoints = {
      s3       = "https://storage.yandexcloud.net"
      dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gft7eo5qqq0f******/etnuh39o6n6ohk*****"
    }
    dynamodb_table = "ssa-diplom-table"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}