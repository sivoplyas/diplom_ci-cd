# diplom_ci-cd
## 1) Создание облачной инфраструктуры

## 1.1 Создание backend s3 для Yandex Cloud storage с блокировками state
Подготавливаем providers.tf по примеру настройки backend s3 для Yandex Cloud storage с блокировками state  (урок "Использование Terraform в команде")

## providers.tf
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

## ssa.tf
 ```javascript
resource "yandex_iam_service_account" "ssa" {
  folder_id = var.folder_id
  name      = "ssa-diplom"
}

resource "yandex_resourcemanager_folder_iam_member" "ssa-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.ssa.id}"
}

resource "yandex_iam_service_account_static_access_key" "ssa-static-key" {
  service_account_id = yandex_iam_service_account.ssa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "diplom" {
  access_key = yandex_iam_service_account_static_access_key.ssa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.ssa-static-key.secret_key
  bucket     = "ssa-bucket"
}

resource "null_resource" "echo_dir" {
  provisioner "local-exec" {
    command = "echo export ACCESS_KEY=${yandex_iam_service_account_static_access_key.ssa-static-key.access_key}"
  }
  provisioner "local-exec" {
    command = "echo export SECRET_KEY=${yandex_iam_service_account_static_access_key.ssa-static-key.secret_key}"
  }
}

resource "yandex_ydb_database_serverless" "ssa-diplom" {
  name                = "ssa-diplom"
  deletion_protection = true
  location_id         = var.default_location
}

resource "yandex_ydb_database_iam_binding" "ssa-bucket-role-database" {
  database_id  = yandex_ydb_database_serverless.ssa-diplom.id
  role         = "editor"
  members      = ["serviceAccount:${yandex_iam_service_account.ssa.id}"]
  depends_on = [yandex_ydb_database_serverless.ssa-diplom]
}

resource "aws_dynamodb_table" "ssa-diplom-table" {
  name         = "ssa-diplom-table"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
  depends_on = [yandex_ydb_database_serverless.ssa-diplom]
}
 ```

## проверяем и применяем код:
## terraform init
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

## 1.2
## проверяем и применяем код:
## terraform init
![222-01](https://github.com/user-attachments/assets/2f9d8039-188d-4b8f-89e4-a88710a6b5a8)

## terraform plan
![222-02](https://github.com/user-attachments/assets/a6862860-79e0-4f55-bf01-e6cd98ba3db1)

## terraform apply
![222-03](https://github.com/user-attachments/assets/e443b863-f611-4279-8ca2-f43e45c0807b)

![222-04](https://github.com/user-attachments/assets/f2a86152-8393-415b-bcb9-e411d0c2b2af)
![222-05](https://github.com/user-attachments/assets/c15d07bf-672d-4772-ba79-f4a881165d27)
![222-06](https://github.com/user-attachments/assets/04782b46-c9fa-4f0e-beee-58bb2c269266)
![222-07](https://github.com/user-attachments/assets/86d8a194-e0f0-4209-b3b2-924e1fdfe0d3)
![222-08](https://github.com/user-attachments/assets/9bd4e83d-735f-499c-b475-64fe6ef3dacd)
![222-09](https://github.com/user-attachments/assets/9293132c-31f6-48ee-b9ec-6af8cd324577)


## terraform destroy
![222-10](https://github.com/user-attachments/assets/5925af69-9038-47d7-824f-7cb2c1e85699)
