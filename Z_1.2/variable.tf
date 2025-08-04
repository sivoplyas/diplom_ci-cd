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

variable "secret_key" {
  type        = string
  description = "secret_key"
}

variable "access_key" {
  type        = string
  description = "access_key"
}

variable "vpc_name" {
  type        = string
  default     = "ssa_network"
  description = "VPC network&subnet name"
}

variable "subnet1" {
  type        = string
  default     = "ssa_network_subnet1"
  description = "subnet name"
}

variable "subnet2" {
  type        = string
  default     = "ssa_network_subnet2"
  description = "subnet name"
}

variable "zone1" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "zone2" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "cidr1" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "cidr2" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}


variable "worker_count" {
  type    = number
  default = 2
}

variable "vm_worker" {
  type = object({
    cpu         = number
    ram         = number
    disk        = number
    core_fraction = number
    platform_id = string
    image_id = string
  })
  default = {
    cpu         = 2
    ram         = 4
    disk        = 10
    core_fraction = 5
    platform_id = "standard-v1"
    image_id = "fd8bv1vdr0alvbbeq6ej"
  }
}

variable "os_image_master" {
  type    = string
  default = "fd8bv1vdr0alvbbeq6ej"
}


variable "vm_master" {
  type        = list(object({
    vm_name = string
    cores = number
    memory = number
    core_fraction = number
    count_vms = number
    platform_id = string
    image_id = string
  }))

  default = [{
      vm_name = "master"
      cores         = 2
      memory        = 4
      core_fraction = 5
      count_vms = 1
      platform_id = "standard-v1"
      image_id = "fd8bv1vdr0alvbbeq6ej"
    }]
}

variable "boot_disk" {
  type        = list(object({
    size = number
    type = string
    }))
    default = [ {
    size = 10
    type = "network-hdd"
  }]
}

variable "default_user" {
  type    = string
  default = "ubuntu"
}

variable "serial_port" {
  type        = number
  default     = 0
  description = "This virtual machine serial port is enable (1-yes,0-no)?"
}
