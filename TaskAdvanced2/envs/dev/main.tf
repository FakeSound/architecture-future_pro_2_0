terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }

  backend "s3" {
    bucket   = "tfstate-budushchee"
    key      = "dev/terraform.tfstate"
    region   = "ru-central1"
    endpoint = "https://storage.yandexcloud.net"

    # Yandex Object Storage не поддерживает эти проверки AWS
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true

    # Credentials передаются через переменные окружения:
    # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
    # (статические ключи сервисного аккаунта Yandex Cloud)
  }
}

provider "yandex" {
  # Локально:  YC_TOKEN + YC_CLOUD_ID + YC_FOLDER_ID
  # В CI:      YC_SERVICE_ACCOUNT_KEY_FILE + YC_CLOUD_ID + YC_FOLDER_ID
}

variable "env_vm_name"   {}
variable "env_cores"     {}
variable "env_memory"    {}
variable "env_subnet_id" {}
variable "env_ssh_key"   {}
variable "env_image_id"  {}
variable "env_disk_size" {}
variable "env_zone"      {}

module "vm" {
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

output "vm_id"       { value = module.vm.vm_id }
output "external_ip" { value = module.vm.external_ip }
output "disk_id"     { value = module.vm.extra_disk_id }
