# Основные параметры подключения
variable "yc_token" {
  type        = string
  sensitive   = true
  description = "Yandex Cloud OAuth token или IAM-токен"
  validation {
    condition     = length(var.yc_token) > 32
    error_message = "Токен должен быть не менее 32 символов"
  }
}

variable "cloud_id" {
  type        = string
  description = "Идентификатор облака Yandex Cloud"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{5,61}[a-z0-9]$", var.cloud_id))
    error_message = "Неверный формат cloud_id (должен соответствовать regex: ^[a-z][a-z0-9-]{5,61}[a-z0-9]$)"
  }
}

variable "folder_id" {
  type        = string
  description = "Идентификатор каталога Yandex Cloud"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{5,61}[a-z0-9]$", var.folder_id))
    error_message = "Неверный формат folder_id (должен соответствовать regex: ^[a-z][a-z0-9-]{5,61}[a-z0-9]$)"
  }
}

# Настройки сети
variable "vpc_name" {
  type        = string
  default     = "k8s-vpc"
  description = "Наименование создаваемой VPC сети"
  validation {
    condition     = length(var.vpc_name) >= 3 && length(var.vpc_name) <= 63 && can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.vpc_name))
    error_message = "Имя VPC должно быть от 3 до 63 символов, начинаться и заканчиваться буквой/цифрой, содержать только a-z, 0-9 и дефисы"
  }
}

variable "subnets" {
  type = map(object({
    zone = string
    cidr = string
    labels = optional(map(string), {
      terraform   = "true"
      subnet-type = "private"
    })
  }))
  default = {
    "subnet-a" = {
      zone = "ru-central1-a"
      cidr = "192.168.10.0/24"
    },
    "subnet-b" = {
      zone = "ru-central1-b"
      cidr = "192.168.20.0/24"
    },
    "subnet-d" = {
      zone = "ru-central1-d"
      cidr = "192.168.30.0/24"
    }
  }
  description = "Конфигурация подсетей в формате: { имя_подсети = { zone = \"зона\", cidr = \"диапазон\" } }"
  validation {
    condition = alltrue([
      for k, v in var.subnets :
      contains(["ru-central1-a", "ru-central1-b", "ru-central1-c", "ru-central1-d"], v.zone)
    ])
    error_message = "Неподдерживаемая зона доступности"
  }
}

# Настройки S3 бакета (опционально)
variable "create_s3_bucket" {
  type        = bool
  default     = true
  description = "Создавать ли S3 бакет для хранения состояния Terraform"
}

variable "s3_bucket_name" {
  type        = string
  default     = "terraform-state-bucket"
  description = "Имя S3 бакета для хранения состояния Terraform"
  validation {
    condition     = length(var.s3_bucket_name) >= 3 && length(var.s3_bucket_name) <= 63 && can(regex("^[a-z0-9.-]+$", var.s3_bucket_name))
    error_message = "Имя бакета должно быть 3-63 символа, содержать только a-z, 0-9, точки и дефисы"
  }
}

variable "s3_access_key" {
  type        = string
  default     = null
  sensitive   = true
  description = "Существующий ключ доступа S3 (если не указан, будет создан новый)"
}

variable "s3_secret_key" {
  type        = string
  default     = null
  sensitive   = true
  description = "Существующий секретный ключ S3 (если не указан, будет создан новый)"
}
