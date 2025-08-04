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

