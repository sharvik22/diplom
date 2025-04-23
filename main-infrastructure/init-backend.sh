#!/bin/bash
set -e

# Путь к проекту
PROJECT_DIR="/home/admon/Diplom/main-infrastructure"
cd "$PROJECT_DIR"

# Проверяем, что переменные окружения заданы
if [[ -z "$YC_S3_BUCKET_NAME" || -z "$YC_S3_ACCESS_KEY" || -z "$YC_S3_SECRET_KEY" ]]; then
  echo "Ошибка: сначала экспортируйте переменные:"
  echo "export YC_S3_BUCKET_NAME='terraform-busket'"
  echo "export YC_S3_ACCESS_KEY='ваш_access_key'"
  echo "export YC_S3_SECRET_KEY='ваш_secret_key'"
  exit 1
fi

# Создаем временный конфиг бэкенда
CONFIG_FILE="backend.auto.tf"
cat > "$CONFIG_FILE" <<EOF
terraform {
  backend "s3" {
    endpoint                    = "https://storage.yandexcloud.net"
    bucket                      = "$YC_S3_BUCKET_NAME"
    key                         = "main-infrastructure/terraform.tfstate"
    region                      = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    access_key                  = "$YC_S3_ACCESS_KEY"
    secret_key                  = "$YC_S3_SECRET_KEY"
  }
}
EOF

# Инициализируем бэкенд
echo "Инициализируем бэкенд с bucket: $YC_S3_BUCKET_NAME"
rm -rf .terraform* 2>/dev/null || true
terraform init -reconfigure -force-copy

# Удаляем временный файл через 15 секунд
(
  sleep 15
  if [ -f "$CONFIG_FILE" ]; then
    rm -f "$CONFIG_FILE"
    echo "Файл $CONFIG_FILE автоматически удален"
  fi
) &

echo "Готово! Бэкенд для main-infrastructure настроен."
echo "State-файл: $YC_S3_BUCKET_NAME/main-infrastructure/terraform.tfstate"
