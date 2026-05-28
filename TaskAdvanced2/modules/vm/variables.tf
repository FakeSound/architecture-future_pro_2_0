variable "vm_name" {
  type        = string
  description = "Имя виртуальной машины"
}

variable "cores" {
  type        = number
  description = "Количество ядер CPU"
}

variable "memory" {
  type        = number
  description = "Объем оперативной памяти в ГБ"
}

variable "subnet_id" {
  type        = string
  description = "ID подсети"
}

variable "ssh_public_key" {
  type        = string
  description = "Публичный SSH-ключ"
}

variable "boot_image_id" {
  type        = string
  description = "ID образа ОС"
}

variable "extra_disk_size" {
  type        = number
  description = "Размер дополнительного диска (ГБ)"
  default     = 10
}

variable "zone" {
  type        = string
  description = "Зона доступности"
  default     = "ru-central1-a"
}
