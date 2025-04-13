terraform {
  backend "s3" {
    bucket     = "terraform-busket"
    key        = "main-infrastructure/terraform.tfstate"
    region     = "ru-central1"
    endpoint   = "https://storage.yandexcloud.net"
    skip_region_validation = true
  }
}
