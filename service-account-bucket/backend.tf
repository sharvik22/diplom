#создает bucket terraform-state-file
resource "yandex_storage_bucket" "terraform_state" {
  bucket        = "terraform-busket"
  force_destroy = true
  acl           = "private"
  folder_id     = var.folder_id

  versioning {
    enabled = true
  }
}

output "bucket_name" {
  value = yandex_storage_bucket.terraform_state.bucket
}

