terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.84.0"
    }
  }
  required_version = ">= 0.84.0"
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.subnets["subnet-a"].zone
  service_account_key_file = file("${path.module}/authorized_key.json")
}
