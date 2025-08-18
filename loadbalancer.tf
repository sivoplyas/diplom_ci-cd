resource "yandex_lb_target_group" "ssa_tg" {
  name      = "ssa-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.ssa_network_subnet1.id
    address   = yandex_compute_instance.worker.0.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.ssa_network_subnet2.id
    address   = yandex_compute_instance.worker.1.network_interface.0.ip_address
  }
}


resource "yandex_lb_network_load_balancer" "ssa-loadbalancer" {
  name = "ssa-load-balancer"
  listener {
    name = "ssa-load-balancer-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.ssa_tg.id
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}
