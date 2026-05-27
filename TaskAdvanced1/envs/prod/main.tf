terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  # YC_TOKEN, YC_CLOUD_ID, YC_FOLDER_ID
}

variable "env_vm_name"    {}
variable "env_cores"      {}
variable "env_memory"     {}
variable "env_subnet_id"  {}
variable "env_ssh_key"    {}
variable "env_image_id"   {}
variable "env_disk_size"  {}
variable "env_zone"       {}

module "production_vm" {
  source = "../../modules/vm"

  vm_name         = var.env_vm_name
  cores           = var.env_cores
  memory          = var.env_memory
  subnet_id       = var.env_subnet_id
  ssh_public_key  = var.env_ssh_key
  boot_image_id   = var.env_image_id
  extra_disk_size = var.env_disk_size
  zone            = var.env_zone
}

output "prod_vm_id"          { value = module.production_vm.vm_id }
output "prod_vm_external_ip" { value = module.production_vm.external_ip }
output "prod_extra_disk_id"  { value = module.production_vm.extra_disk_id }
