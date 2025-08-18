# diplom_ci-cd
## 1) Создание облачной инфраструктуры

## 1.1 Создание backend s3 для Yandex Cloud storage с блокировками state
Подготавливаем providers.tf по примеру настройки backend s3 для Yandex Cloud storage с блокировками state  (урок "Использование Terraform в команде")

### providers.tf
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

### ssa.tf
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

### проверяем и применяем код:
### terraform init
![111-01](https://github.com/user-attachments/assets/ff5da5cf-7178-4c6c-955b-e86dd2e26782)

### terraform plan
![111-02](https://github.com/user-attachments/assets/d3d7f2dd-28ab-4f3e-9e52-c042ccdeeefe)

### terraform apply
![111-03](https://github.com/user-attachments/assets/716c70c2-7191-4fb4-8bc0-6d009eef2a73)

### Проверяем результат:
Создался сервисный аккаунт "ssa-diplom", который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами - ролью "editor". 
![111-04](https://github.com/user-attachments/assets/01055984-f5c4-4e4c-b98c-428cddb4eda0)

### cоздался bucket с именем "ssa-bucket" для хранения tfstate.
![111-05](https://github.com/user-attachments/assets/3ee3e32e-d8de-4b44-af02-8de4371c2354)

### для сервисного аккаунта "ssa-diplom" добавлена роль "ydb.editor"
![111-06](https://github.com/user-attachments/assets/83ade725-e2e5-492f-bf54-0b385822f81c)

### cоздалась база данных ydb "ssa-diplom" и в ней таблица "ssa-diplom-table" для хранения блокировок (урок "Использование Terraform в команде")
![111-08](https://github.com/user-attachments/assets/53b1e78c-064d-4c39-b0ec-52861c9d802c)
![111-07](https://github.com/user-attachments/assets/0f8b4b54-02de-4157-9d1e-db0fcfe5c780)

## 1.2 Создаем инфраструктуру
### network.tf (создаем сети)
 ```javascript
resource "yandex_vpc_network" "ssa_network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "ssa_network_subnet1" {
  name           = var.subnet1
  zone           = var.zone1
  network_id     = yandex_vpc_network.ssa_network.id
  v4_cidr_blocks = var.cidr1
}

resource "yandex_vpc_subnet" "ssa_network_subnet2" {
  name           = var.subnet2
  zone           = var.zone2
  network_id     = yandex_vpc_network.ssa_network.id
  v4_cidr_blocks = var.cidr2
}
 ```
### instans_m_w.tf (создание master и worker)
 ```javascript
resource "yandex_compute_instance" "master" {
  name        = "${var.vm_master[0].vm_name}"
  platform_id = var.vm_master[0].platform_id
  allow_stopping_for_update = true
  count = var.vm_master[0].count_vms
  zone = var.zone1
  resources {
    cores         = var.vm_master[0].cores
    memory        = var.vm_master[0].memory
    core_fraction = var.vm_master[0].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_master[0].image_id
      type     = var.boot_disk[0].type
      size     = var.boot_disk[0].size
    }
  }

  metadata = {
    ssh-keys = "${var.default_user}:${local.public_ssh_key_pub}"
    serial-port-enable = var.serial_port
    #user-data          = data.template_file.cloudinit.rendered
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.ssa_network_subnet1.id
    nat       = true
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "worker" {
  depends_on = [yandex_compute_instance.master]
  count      = var.worker_count
  allow_stopping_for_update = true
  name          = "worker-${count.index + 1}"
  platform_id   = var.vm_worker.platform_id
  zone = "worker-${count.index + 1}" == "worker-1" ? var.zone1 : var.zone2
  resources {
    cores         = var.vm_worker.cpu
    memory        = var.vm_worker.ram
    core_fraction = var.vm_worker.core_fraction
    }
   boot_disk {
    initialize_params {
        image_id     = var.vm_worker.image_id
        type         = var.boot_disk[0].type
        size         = var.boot_disk[0].size
    }
  }

  metadata = {
    ssh-keys           = "${var.default_user}:${local.public_ssh_key_pub}"
    serial-port-enable = var.serial_port
    #user-data          = data.template_file.cloudinit.rendered
  }

  network_interface {
    subnet_id          = "worker-${count.index + 1}" == "worker-1" ? yandex_vpc_subnet.ssa_network_subnet1.id : yandex_vpc_subnet.ssa_network_subnet2.id
    nat                = true
  }

  scheduling_policy {
    preemptible = true
  }
}
 ```
### s3.tf (использование bucket для хранения diplom.tfstate и базы данных ydb "ssa-diplom" и таблица "ssa-diplom-table" для хранения блокировок). Нужно из п.1.1 файла terraform.tfstate взять значение document_api_endpoint и записать его в dynamodb 
 ```javascript
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
 ```
### !!! Перед проверкой нам нужно из п.1.1 файла terraform.tfstate взять secret_key и access_key и записать их в s3.config
![222-3](https://github.com/user-attachments/assets/3ed399cb-c663-43b0-b07a-dad58fb93514)

### проверяем и применяем код:
### terraform init -backend-config=s3.config
![222-01](https://github.com/user-attachments/assets/2f9d8039-188d-4b8f-89e4-a88710a6b5a8)

### terraform plan
![222-02](https://github.com/user-attachments/assets/a6862860-79e0-4f55-bf01-e6cd98ba3db1)

### terraform apply
![222-03](https://github.com/user-attachments/assets/e443b863-f611-4279-8ca2-f43e45c0807b)

### Проверяем результат:
### созданы 3 виртуальные машины и сети
![222-04](https://github.com/user-attachments/assets/f2a86152-8393-415b-bcb9-e411d0c2b2af)
### создана сеть
![222-05](https://github.com/user-attachments/assets/c15d07bf-672d-4772-ba79-f4a881165d27)
### созданы 2 подсети в разных зонах
![222-06](https://github.com/user-attachments/assets/04782b46-c9fa-4f0e-beee-58bb2c269266)
### созданы 3 виртуальные машины (2 workers и 1 master) в разных зонах
![222-07](https://github.com/user-attachments/assets/86d8a194-e0f0-4209-b3b2-924e1fdfe0d3)
### в s3 бакете "ssa-bucket" записался diplom.tfstate
![222-08](https://github.com/user-attachments/assets/9bd4e83d-735f-499c-b475-64fe6ef3dacd)
### в таблице ssa-diplom-table базы данных ssa-diplom появилась запись
![222-09](https://github.com/user-attachments/assets/9293132c-31f6-48ee-b9ec-6af8cd324577)
### terraform destroy выполнился без ошибок
![222-10](https://github.com/user-attachments/assets/5925af69-9038-47d7-824f-7cb2c1e85699)

## 2) Создание Kubernetes кластера
Выполняем п. 1.2 Создаем инфраструктуру без команды destroy

### Инфраструктура поднялась.
![333-0000](https://github.com/user-attachments/assets/4a402002-c405-4548-8dc5-cbe6e5b755bf)

### Заполняем файл inventory.ini в каталоге inventory
![333-001](https://github.com/user-attachments/assets/7cdf347b-c6ce-49e0-99dd-037c4b95b14f)

### Изменяем файл kubespray_install.sh
![333-002](https://github.com/user-attachments/assets/1cf88681-a366-4982-a9af-2abb3f092be9)

### Запускаем bash файл: sh kubespray_install.sh
![333-1](https://github.com/user-attachments/assets/b008facd-d976-4156-99e6-382cb42edd5e)

### Ожидаем окончание выполнения...
![333-2](https://github.com/user-attachments/assets/dde6b7aa-be61-48f1-a7a2-1714dee78b38)

### Подключаемся к master (ssh 51.250.2.178) переходим в root и выполняем команду...
![333-3](https://github.com/user-attachments/assets/7d8bd310-77ba-449f-870e-281fe769a569)

### Копируем config на локальную машину и правим его...
### Выполняем команду на локальной машине
![333-4](https://github.com/user-attachments/assets/322eb98d-327a-428c-a884-8f2313da23d0)

## 3) Создание тестового приложения
### Создаем образ на локальной машине (docker build -t nginx:ssa .) и проверяем его работоспособность
![444-1](https://github.com/user-attachments/assets/e1fb6dff-b31b-4586-9b47-ee584a7f8357)

### Создаем в своем GitHub Package Registry (https://hub.docker.com) публичный репозиторий и создаем для данного репозитория токен с правами чтение и запись
![444-2](https://github.com/user-attachments/assets/b04b3ae1-5d90-48d5-aa5a-74d396f99f50)

### Создаем публичный репозиторий для тестового приложения куда и отправляем файлы для создания образа ![diplom_test_application](https://github.com/sivoplyas/diplom_test_application)
![444-7](https://github.com/user-attachments/assets/098fcf25-4c60-4906-a13f-469ae4ef381a)

### Создаем секреты для работы с GitHub Package Registry и Kubernetes
![444-4](https://github.com/user-attachments/assets/e5a69ad5-e234-443d-9faa-7d5331ad52f8)

### Полагаем что любые коммиты в репозитории с тестовым приложением будут проводиться в ветке отличной от “main”. Пишем код..
![444-5](https://github.com/user-attachments/assets/3e9cf50d-dd75-46ce-a929-24927a321df1)

### Выполнение Workflow Docker Build
![444-8](https://github.com/user-attachments/assets/b45b481a-c0ee-4686-ac8d-8be5b31230a5)

### Проверка создания образа в GitHub Package Registry c тегом latest
![444-6](https://github.com/user-attachments/assets/f0321711-90f3-4671-92c3-8e74599a98ae)

## 4) Установка и настройка CI/CD

### Полагаем что создании тега (начинающего с буквы v) будет присваиваться только в ветке main. При создании тега происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes
 ```javascript
name: Docker Deploy
on:
  push:
    tags:
      - 'v*'
env:
    REGISTRY: docker.io
    IMAGE_NAME: diplom-ssa
jobs:
    build:
        runs-on: ubuntu-latest

        steps:
            - name: Checkout code
              uses: actions/checkout@v2

            - name: Log in to the Container registry
              uses: docker/login-action@v1
              with:
                registry: ${{ env.REGISTRY }}
                username: ${{ secrets.DOCKER_USER }}
                password: ${{ secrets.DOCKER_TOKEN }}

            - name: Extract metadata (tags, labels) for Docker
              id: meta
              uses: docker/metadata-action@v2
              with:
                images: ${{ env.REGISTRY }}/${{ github.ref_name }}
            
            - name: Build and push Docker image
              uses: docker/build-push-action@v2
              with:
                context: .
                push: true
                tags: ${{ secrets.DOCKER_USER }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}

            - name: Deploy k8s
              run: |
                mkdir -p ~/.kube && echo "${{ secrets.KUBE_CONFIG_BASE64_DATA }}" | base64 -d > ~/.kube/config
                helm upgrade --install ssa-app-test -f ./helm/values.yaml ./helm/. --namespace ssa --create-namespace --wait --set image.repository="${{ secrets.DOCKER_USER }}/${{ env.IMAGE_NAME }}" --set image.tag="${{ github.ref_name }}"
 ```
### Развертывание в Kubernetes выполняем через Helm Chart
![555-0](https://github.com/user-attachments/assets/e736795e-eeac-40d1-9877-380d0ca06da7)
![555-1](https://github.com/user-attachments/assets/63d1f7ec-0090-47ab-82df-a286e020bae3)
![555-3](https://github.com/user-attachments/assets/1854a9d9-d7fe-42e1-b6b8-18526e60815f)

## Headless Services
![555-2](https://github.com/user-attachments/assets/40cf3267-8400-4b93-a385-235e40f19267)

### Устанавливаем тег для тестового приложения v1.0.3
![555-4](https://github.com/user-attachments/assets/05bf4fd0-032e-499f-81ef-d50510b9a6a1)

### Выполнение Workflow Docker Deploy
![555-5](https://github.com/user-attachments/assets/163dee98-759d-42f7-9dcc-558920ce255e)

### Проверяем развертывание в Kubernetes
![555-6](https://github.com/user-attachments/assets/34162bf6-4f17-4307-bfb2-5122a8468cfe)
![555-7](https://github.com/user-attachments/assets/fe6c6b07-ec27-4936-afe8-5accb3998fef)
![555-8](https://github.com/user-attachments/assets/e0071e86-040a-4c95-821b-7b6c032ad754)
![555-9](https://github.com/user-attachments/assets/0201b658-6af0-4a2b-8573-d5bfcc78bf5a)



