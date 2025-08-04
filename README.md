# diplom_ci-cd
## 1) Создание облачной инфраструктуры
##Code
 ```javascript
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
```
## провяем код:
terraform init
![111-01](https://github.com/user-attachments/assets/ff5da5cf-7178-4c6c-955b-e86dd2e26782)

## terraform plan
![111-02](https://github.com/user-attachments/assets/d3d7f2dd-28ab-4f3e-9e52-c042ccdeeefe)

## terraform apply
![111-03](https://github.com/user-attachments/assets/716c70c2-7191-4fb4-8bc0-6d009eef2a73)


## Проверяем результат:
Создался сервисный аккаунт "ssa-diplom", который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами - ролью "editor". 
![111-04](https://github.com/user-attachments/assets/01055984-f5c4-4e4c-b98c-428cddb4eda0)

## cоздался bucket с именем "ssa-bucket" для хранения tfstate.
![111-05](https://github.com/user-attachments/assets/3ee3e32e-d8de-4b44-af02-8de4371c2354)

## для сервисного аккаунта "ssa-diplom" добавлена роль "ydb.editor"
![111-06](https://github.com/user-attachments/assets/83ade725-e2e5-492f-bf54-0b385822f81c)

## cоздалась база данных ydb "ssa-diplom" и в ней таблица "ssa-diplom-table" для хранения блокировок (урок "Использование Terraform в команде")
![111-08](https://github.com/user-attachments/assets/53b1e78c-064d-4c39-b0ec-52861c9d802c)
![111-07](https://github.com/user-attachments/assets/0f8b4b54-02de-4157-9d1e-db0fcfe5c780)
