output "vm_id" {
  value       = yandex_compute_instance.vm.id
  description = "ID виртуальной машины"
}

output "vm_name" {
  value       = yandex_compute_instance.vm.name
  description = "Имя виртуальной машины"
}

output "internal_ip" {
  value       = yandex_compute_instance.vm.network_interface.0.ip_address
  description = "Внутренний IP"
}

output "external_ip" {
  value       = yandex_compute_instance.vm.network_interface.0.nat_ip_address
  description = "Внешний IP"
}

output "extra_disk_id" {
  value       = yandex_compute_disk.extra_disk.id
  description = "ID дополнительного диска"
}
