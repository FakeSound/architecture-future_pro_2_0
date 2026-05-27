terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

# Дополнительный диск
resource "yandex_compute_disk" "extra_disk" {
  name = "${var.vm_name}-extra-disk"
  size = var.extra_disk_size
  type = "network-hdd"
  zone = var.zone
}

# Виртуальная машина
resource "yandex_compute_instance" "vm" {
  name        = var.vm_name
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.boot_image_id
    }
  }

  # Подключение дополнительного диска
  secondary_disk {
    disk_id = yandex_compute_disk.extra_disk.id
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true # Включаем публичный IP (если нужно)
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
