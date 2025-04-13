# Yandex Cloud Auth
variable "yc_token" {
  type        = string
  sensitive   = true
  description = "Yandex Cloud OAuth или IAM-токен"
}

variable "cloud_id" {
  type        = string
  description = "ID облака в Yandex Cloud"
}

variable "folder_id" {
  type        = string
  description = "ID каталога в Yandex Cloud"
}

# SSH & Service Account
variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "SSH-ключ для доступа к ВМ (формат: 'ssh-rsa AAA...')"
}

# Объединенное объявление переменной (удален дубль)
variable "service_account_id" {
  type        = string
  description = "ID сервисного аккаунта для ВМ"
  sensitive   = true
}

# Network
variable "subnets" {
  type = map(object({
    id   = string
    zone = string
  }))
  description = "Map существующих подсетей в формате: { subnet-name = { id = \"...\", zone = \"...\" } }"
}

variable "vpc_id" {
  type        = string
  description = "ID существующей VPC сети"
}

# VM Settings
variable "vm_image_id" {
  type        = string
  default     = "fd8vmcue7aajpmeo39kk" # Ubuntu 20.04 LTS
  description = "ID образа для ВМ"
}

variable "vm_user" {
  type        = string
  default     = "ubuntu"
  description = "Пользователь по умолчанию"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "Default zone for resources"
}

# Security Group
variable "k8s_security_group_id" {
  type        = string
  description = "ID Security Group для Kubernetes"
  sensitive   = true
}
