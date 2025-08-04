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
