# diplom_ci-cd
## 1) Создание облачной инфраструктуры
провяем код:
terraform init
![111-01](https://github.com/user-attachments/assets/ff5da5cf-7178-4c6c-955b-e86dd2e26782)

terraform plan
![111-02](https://github.com/user-attachments/assets/d3d7f2dd-28ab-4f3e-9e52-c042ccdeeefe)

terraform apply
![111-03](https://github.com/user-attachments/assets/51f79ea5-a37c-4f2b-b294-d6971d1d3b10)

Проверяем результат:
Создался сервисный аккаунт "ssa-diplom", который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами - ролью "editor". 
![111-04](https://github.com/user-attachments/assets/01055984-f5c4-4e4c-b98c-428cddb4eda0)

Создался bucket с именем "ssa-bucket" для хранения tfstate.
![111-05](https://github.com/user-attachments/assets/3ee3e32e-d8de-4b44-af02-8de4371c2354)

Для сервисного аккаунта "ssa-diplom" добавлена роль "ydb.editor"
![111-06](https://github.com/user-attachments/assets/83ade725-e2e5-492f-bf54-0b385822f81c)

Создалась база данных ydb "ssa-diplom" и в ней таблица "ssa-diplom-table" для хранения
![111-08](https://github.com/user-attachments/assets/53b1e78c-064d-4c39-b0ec-52861c9d802c)
![111-07](https://github.com/user-attachments/assets/0f8b4b54-02de-4157-9d1e-db0fcfe5c780)
