# Дипломный практикум в Yandex.Cloud

 *студента группы № fops-18_shclopro-9*  

## Шарапат Виктора

## `Цели:`

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.



## Этапы выполнения:

 ### 1. `Создание облачной инфраструктуры`

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://developer.hashicorp.com/terraform/language/backend) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://developer.hashicorp.com/terraform/language/backend) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

`Ожидаемые результаты:`

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### `Решение`

Я подготовил и настроил локальную ВМ (terraform) для работы с Yandex Cloud (YC).

!!!!!!!!!!!!ВАЖНО НУЖНО ДОБОВЛЯТЬ ПЕРЕМЕННУЮ В НОВОЙ КОНСОЛИ!!!!!!!!!!

export TF_VAR_yc_token="y0__xCrtai1BhjB3RMgw6D_kRLkvbL06g_BP0APHxh0iMLN5_gMuQ"

export TF_VAR_cloud_id="b1g811k1u7vur9c50o56"

export TF_VAR_folder_id="b1guevbvpqmirfgfolig"

export TF_VAR_default_zone="ru-central1-a"

export TF_VAR_ssh_public_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGtGgCucF4rB9fJftdS3o6muoClGVjxpTDxhoY3AEkCI root@terraform"

export TF_VAR_service_account_id="ajerb3ipngse8f0ut4cu"

### При создании аккаунта надо создать новый authorized_key.json





Перед деплоем нв github
Локальная проверка и автоматическое исправление
terraform fmt -recursive

Запустите команду для проверки синтаксиса:
terraform validate





`Ожидаемые результаты:`

При выполнении `terraform destroy` будет возникать ошибка: 
Вы пытаетесь удалить бакет terraform-busket, но он не пустой. Yandex Cloud не позволяет удалить бакет, если в нём есть файлы.

`Решение:` зайти YC и вручную удалить 

---

### 2. `Создание Kubernetes кластера`

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

### `Решение`
*********************************************************
Клонировать репозиторий
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
cp -rfp inventory/sample inventory/mycluster
nano inventory/mycluster/inventory.ini

Версия V
nano inventory/mycluster/group_vars/all/all.yml

Установка дополнительных компонентов
nano inventory/mycluster/group_vars/k8s_cluster/addons.yml

# Мониторинг
helm_enabled: true
metrics_server_enabled: true
dashboard_enabled: true

# Логирование
efk_enabled: false
elasticsearch_enabled: false

# Ingress контроллер
ingress_nginx_enabled: true


пинг
ansible -i inventory/mycluster/inventory.ini all -m ping --become

Запуск
ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root --user=ubuntu cluster.yml
ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root --user=ubuntu cluster.yml -vvv

worker1
ssh -l ubuntu 84.252.136.185
master
ssh -l ubuntu 51.250.79.130
worker2
ssh -l ubuntu 158.160.156.120

Важно вручную если что
sudo hostnamectl set-hostname master
sudo hostnamectl set-hostname worker1
sudo hostnamectl set-hostname worker2

sudo mkdir -p /etc/bash_completion.d
sudo chmod 755 /etc/bash_completion.d

nano /etc/sudoers
ubuntu  ALL=(ALL:ALL) NOPASSWD: ALL

nano inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

systemctl status systemd-hostnamed
sudo systemctl start systemd-hostnamed


Проверка
master
ssh -l ubuntu 158.160.101.52
sudo su
kubectl get nodes
nano ~/.kube/config
kubectl get pods --all-namespaces

ssh ubuntu@158.160.108.186 sudo -n whoami

Настройка поделючения к кластеру

Установка и настройка kubectl на ВМ terraform
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/


mkdir -p ~/.kube
ssh ubuntu@158.160.108.186 "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config
chmod 600 ~/.kube/config


руководство по настройке SSH-туннеля для доступа к Kubernetes API
Однократное подключение
ssh -N -L 6443:localhost:6443 ubuntu@158.160.108.186

Фоновый режим (с автоподключением)
ssh -f -N -M -S /tmp/kubernetes-tunnel -L 6443:localhost:6443 ubuntu@158.160.108.186
ssh -f -N -M -S /tmp/kubernetes-tunnel -L 6443:127.0.0.1:6443 ubuntu@158.160.108.186

Для закрытия туннеля:
ssh -S /tmp/kubernetes-tunnel -O exit root@158.160.108.186



kubectl get nodes


`Ожидаемые результаты:`


---

### 3. `Создание тестового приложения`

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.


### `Решение`


`Ожидаемые результаты:`


---

### 4. `Подготовка cистемы мониторинга и деплой приложения`

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform

### `Решение`


`Ожидаемые результаты:`


---


### 5. `Установка и настройка CI/CD`

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

### `Решение`


`Ожидаемые результаты:`


---



## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---












