#!/bin/bash
set -euo pipefail

TARGET_DIR="../main-infrastructure"
CONFIG_FILE="${TARGET_DIR}/terraform.auto.tfvars"

# Проверяем, что terraform инициализирован
if ! terraform output -json >/dev/null 2>&1; then
  echo "Ошибка: сначала выполните 'terraform apply' для создания ресурсов"
  exit 1
fi

# Создаем директорию, если ее нет
mkdir -p "$TARGET_DIR"

# Генерируем конфигурационный файл
echo "# Автоматически сгенерировано. Не редактировать вручную!" > "$CONFIG_FILE"
terraform output -json network_summary | \
  jq -r 'to_entries | map("\(.key) = \(.value | tojson)") | join("\n")' >> "$CONFIG_FILE"

# Добавляем пояснения
cat >> "$CONFIG_FILE" <<EOF

# Использование в ресурсах:
# network_interface {
#   subnet_id = existing_subnets["ru-central1-a"].id
#   nat       = true
# }
EOF

echo "Конфигурация сети успешно экспортирована в ${CONFIG_FILE}"
echo "Содержимое файла:"
cat "$CONFIG_FILE"
