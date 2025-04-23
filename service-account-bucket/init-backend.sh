#!/bin/bash
set -e

# Проверяем, что terraform output доступен
if ! terraform output -json > /dev/null 2>&1; then
  echo "Ошибка: сначала выполните 'terraform apply' для создания ресурсов"
  exit 1
fi

# Получаем чистые значения без ANSI-кодов и лишних строк
BUCKET_NAME=$(terraform output -raw bucket_name 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')
ACCESS_KEY=$(terraform output -raw access_key 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')
SECRET_KEY=$(terraform output -raw secret_key 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')

# Проверяем, что значения получены
if [ -z "$BUCKET_NAME" ] || [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
  echo "Ошибка: не удалось получить необходимые значения из вывода Terraform"
  exit 1
fi

# Создаем временный конфигурационный файл
CONFIG_FILE="backend.auto.tf"
cat > "$CONFIG_FILE" <<EOF
terraform {
  backend "s3" {
    endpoint                    = "https://storage.yandexcloud.net"
    bucket                      = "$BUCKET_NAME"
    key                         = "service-account-bucket/terraform.tfstate"
    region                      = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    access_key                  = "$ACCESS_KEY"
    secret_key                  = "$SECRET_KEY"
  }
}
EOF

# Инициализируем Terraform
echo "Инициализируем бэкенд с bucket: $BUCKET_NAME"
rm -rf .terraform* 2>/dev/null || true
terraform init -reconfigure -force-copy

# Выводим инструкции для CI/CD
cat <<EOF

========================================
Для использования в текущей сессии выполните:
export YC_S3_BUCKET_NAME="$BUCKET_NAME"
export YC_S3_ACCESS_KEY="$ACCESS_KEY"
export YC_S3_SECRET_KEY="$SECRET_KEY"

Для CI/CD добавьте секреты:
1. YC_S3_BUCKET_NAME = $BUCKET_NAME
2. YC_S3_ACCESS_KEY = $ACCESS_KEY
3. YC_S3_SECRET_KEY = $SECRET_KEY
========================================
EOF

# Удаляем временный файл в фоновом режиме без блокировки терминала
(
  sleep 15
  if [ -f "$CONFIG_FILE" ]; then
    rm -f "$CONFIG_FILE"
    echo "Файл $CONFIG_FILE автоматически удален" > /dev/tty
  fi
) & disown

echo "Готово! Бэкенд успешно инициализирован."
echo "Файл $CONFIG_FILE будет автоматически удален через 15 секунд."

##########################################
##!/bin/bash
#set -e
#
## Проверяем, что terraform output доступен
#if ! terraform output -json > /dev/null 2>&1; then
#  echo "Ошибка: сначала выполните 'terraform apply' для создания ресурсов"
#  exit 1
#fi
#
## Получаем чистые значения без ANSI-кодов и лишних строк
#BUCKET_NAME=$(terraform output -raw bucket_name 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')
#ACCESS_KEY=$(terraform output -raw access_key 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')
#SECRET_KEY=$(terraform output -raw secret_key 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')
#
## Проверяем, что значения получены
#if [ -z "$BUCKET_NAME" ] || [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
#  echo "Ошибка: не удалось получить необходимые значения из вывода Terraform"
#  exit 1
#fi
#
## Создаем временный конфигурационный файл
#CONFIG_FILE="backend.auto.tf"
#cat > "$CONFIG_FILE" <<EOF
#terraform {
#  backend "s3" {
#    endpoint                    = "https://storage.yandexcloud.net"
#    bucket                      = "$BUCKET_NAME"
#    key                         = "service-account-bucket/terraform.tfstate"
#    region                      = "ru-central1"
#    skip_region_validation      = true
#    skip_credentials_validation = true
#    skip_requesting_account_id  = true
#    access_key                  = "$ACCESS_KEY"
#    secret_key                  = "$SECRET_KEY"
#  }
#}
#EOF
#
## Инициализируем Terraform
#echo "Инициализируем бэкенд с bucket: $BUCKET_NAME"
#rm -rf .terraform* 2>/dev/null || true
#terraform init -reconfigure -force-copy
#
## Выводим команды для экспорта в нужном формате
#cat <<EOF
#
#========================================
#Для использования в текущей сессии выполните:
#export YC_S3_BUCKET_NAME="$BUCKET_NAME"
#export YC_S3_ACCESS_KEY="$ACCESS_KEY"
#export YC_S3_SECRET_KEY="$SECRET_KEY"
#
#Для CI/CD добавьте секреты:
#1. YC_S3_BUCKET_NAME = $BUCKET_NAME
#2. YC_S3_ACCESS_KEY = $ACCESS_KEY
#3. YC_S3_SECRET_KEY = $SECRET_KEY
#========================================
#EOF
#
## Запланируем удаление файла через 15 секунд
#(
#  sleep 15
#  if [ -f "$CONFIG_FILE" ]; then
#    rm -f "$CONFIG_FILE"
#    echo "Файл $CONFIG_FILE автоматически удален"
#  fi
#) &
#
#echo "Готово! Бэкенд успешно инициализирован."
#echo "Файл $CONFIG_FILE будет автоматически удален через 15 секунд."
