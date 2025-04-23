#создается аккаунт с ролью
resource "yandex_iam_service_account" "sa" {
  name        = "service-account-terraform"
  description = "Service account for Terraform"
}

resource "yandex_resourcemanager_folder_iam_binding" "binding" {
  folder_id = var.folder_id
  role      = "editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}
#создаются ключи
resource "yandex_iam_service_account_static_access_key" "sa-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "Static access key for service account"
}

output "access_key" {
  value = yandex_iam_service_account_static_access_key.sa-key.access_key
}

output "secret_key" {
  value     = yandex_iam_service_account_static_access_key.sa-key.secret_key
  sensitive = true
}

