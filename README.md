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
3. Создайте конфигурацию Terraform, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://developer.hashicorp.com/terraform/language/backend) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

`Ожидаемые результаты:`

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### `Решение`

Я подготовил и настроил локальную ВМ (terraform) для работы с Yandex Cloud (YC).

Сделал экспорт необходимых переменных:

* export TF_VAR_yc_token=""
* export TF_VAR_cloud_id=""
* export TF_VAR_folder_id=""
* export TF_VAR_ssh_public_key=""

Структура проекта выглядит следующим образом:

![image](https://github.com/user-attachments/assets/d36b67dc-a933-405e-9244-8ef76f45e878)


В каждый проект добавил файл .gitignore.

# service-account-bucket
 - создает бакет;
 - сервисный аккаунт;
 - сеть (которая будет использоваться в дальнейшем);
 - группу безопасности;

Локальная проверка и автоматическое исправление
* terraform fmt -recursive

Запустите команду для проверки синтаксиса:
* terraform validate

![image](https://github.com/user-attachments/assets/4f98310c-e2b3-4d76-971a-7c93b44def25)

* terraform init

![image](https://github.com/user-attachments/assets/b140fec9-fc64-4839-a0fe-8c03cf501fb7)

* terraform plan

![image](https://github.com/user-attachments/assets/209ce3e5-ecc7-42e4-8f9d-3d5077a7dd62)

* terraform apply


У меня есть два скрипта

* export_network_config.sh - делает инициализацию сети для второго проекта, т.к. буду использовать уже созданную сеть.
  
* init-backend.sh — скрипт для инициализации хранилища state-файлов проекта.

Порядок работы:
* Сначала необходимо создать бакет (у меня это происходит автоматически при выполнении кода).
* Затем с помощью этого скрипта инициализируется хранилище для state-файлов проекта.
* Для инициализации требуется подключение к бакету (нужны ACCESS_KEY и SECRET_KEY).

Как работает скрипт:

* Получает ключи из вывода команды создания бакета.
* Сохраняет их во временный файл.
* Выводит переменные для проверки и экспорта.
* Удаляет временный файл после завершения.



После выполнения terraform apply. 

![image](https://github.com/user-attachments/assets/ebdd608d-5648-436d-a568-e535d3e8ac2f)

![image](https://github.com/user-attachments/assets/97568afd-d857-41ec-a583-74a05f6f5d69)

![image](https://github.com/user-attachments/assets/c535e99d-cc41-4f1d-b24e-c9bd11ac7353)


Далее запускаю скрипты:

![image](https://github.com/user-attachments/assets/814605de-857f-43cd-bca7-a0bdb98892fe)

![image](https://github.com/user-attachments/assets/021f1642-1742-4af5-9a7d-2eea6ce7eec3)

![image](https://github.com/user-attachments/assets/87b9155b-e0c0-46bc-9e43-bb27927275f8)


`Ожидаемые результаты:`

При выполнении `terraform destroy` будет возникать ошибка: "Вы пытаетесь удалить бакет terraform-busket, но он не пустой. Yandex Cloud не позволяет удалить бакет, если в нём есть файлы."


`Решение:` 
* terraform init -migrate-state
* terraform destroy

![image](https://github.com/user-attachments/assets/1cd01a6d-8064-4df5-ad1c-7a91adb6f492)

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

Я разворачиваю кластер с помощью Kubespray. Для этого подготовил и настроил виртуальную машину, на которой установил все необходимые компоненты для работы Ansible и Kubespray.

* добавил ключ ssh для подключения.
* установил sudo apt install python3-pip
* Клонировал репозиторий  git clone https://github.com/netology-code/ter-homeworks.git
* установил зависимости sudo pip install -r requirements.txt --break-system-packages --ignore-installed
* скопировал инвентори cp -rfp inventory/sample inventory/mycluster

* установил Helm на локальную машину
* curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
* sudo apt-get install apt-transport-https --yes
* echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
* sudo apt-get update
* sudo apt-get install helm
* helm version

* установка дополнительных компонентов
- nano inventory/mycluster/group_vars/k8s_cluster/addons.yml

# Мониторинг
- helm_enabled: true
- metrics_server_enabled: true
- dashboard_enabled: true

# Логирование
- efk_enabled: false
- elasticsearch_enabled: false

# Ingress контроллер
- ingress_nginx_enabled: true

Так же, сделал экспорт необходимых переменных для бакета и сервисного аккаунта, которые были созданы в первом проекте.

- export TF_VAR_k8s_security_group_id=""
- export TF_VAR_service_account_id=""
- export YC_S3_BUCKET_NAME=""
- export YC_S3_ACCESS_KEY=""
- export YC_S3_SECRET_KEY=""

Для сервисного аккаунта создаю  ключ авторизации в формате json через yandex. 


Структура проекта:

![image](https://github.com/user-attachments/assets/c9151889-642a-4f6f-bd86-399dc99bfe61)


# main-infrastructure
 - хранение стейт файла проекта;
 - создание трех ВМ для кластера;
 - создание Network Load Balancer;


После выполнения terraform apply.

![image](https://github.com/user-attachments/assets/943278c0-a13f-44ad-9308-c8c761b5f903)


Так же запускаю скрипт init-backend.sh для хранения стейт файла второго проекта.

![image](https://github.com/user-attachments/assets/ba4389e8-6c4c-4e52-8a7e-1e303d890999)


Все необходимые компоненты для создания кластера успешно развернуты.

![image](https://github.com/user-attachments/assets/40cdd1d9-f896-4fb9-a6af-44a87aa93814)


Настроил inventory (вывод outputs.tf), ввел данные ip master и workers.

![image](https://github.com/user-attachments/assets/339f4877-9a76-4a3a-9feb-ab4aad6e5823)


Произвел проверку доступности.

* ansible -i inventory/mycluster/inventory.ini all -m ping --become

![image](https://github.com/user-attachments/assets/6ca3ac46-b08f-4fba-9231-e07f72e8b1eb)


Запустил создание кластера.

* ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root --user=ubuntu cluster.yml -vvv

### Итог:

![image](https://github.com/user-attachments/assets/e08227de-dc30-49f1-9222-e1b5c5ac79bd)


Далее настроиваю подключение к кластеру.

Установка и настройка kubectl. 

* curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
* chmod +x kubectl
* sudo mv kubectl /usr/local/bin/

На ВМ ansible.

* mkdir -p ~/.kube
* ssh ubuntu@84.252.131.153 "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config
* chmod 600 ~/.kube/config
* nano ~/.kube/config


Настроил SSH-туннеля для доступа к Kubernetes API.

Фоновый режим (с автоподключением).

ssh -f -N -M -S /tmp/kubernetes-tunnel -L 6443:127.0.0.1:6443 ubuntu@84.252.131.153


`Ожидаемые результаты:`

![image](https://github.com/user-attachments/assets/516b23ce-5428-446e-a16c-4ed44522a008)


Подключение к master

![image](https://github.com/user-attachments/assets/80f20635-c898-4c4a-918e-4666a8501390)

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

* На ВМ установил и настроил docker.

![image](https://github.com/user-attachments/assets/201167a7-f319-4797-8bfc-9c61b2ba4ad1)


* Создал Token для DockerHub.

![image](https://github.com/user-attachments/assets/c2aa63c7-c328-41fe-94a6-145c45a01a2e)


 * Экспортировал переменную.

 export TF_VAR_dockerhub_token=""


* Создал Git репозиторий, настроил ssh авторизацию (nginx-app).
												
* Клонировал репозиторий.
 
git clone https://github.com/sharvik22/nginx-app.git

* Создал структуру для nginx с конфигом.

![image](https://github.com/user-attachments/assets/c0327094-f8db-421f-9490-4a2830f75685)


* Произвел сборку образа.

docker build -t sharvik40/nginx-app:latest .

![image](https://github.com/user-attachments/assets/d54242bc-731b-463e-92b7-da2ff3802cfd)

![image](https://github.com/user-attachments/assets/4e6ed87d-0829-4374-92c2-7774a99b4c0e)


* Делаю деплой образа в DockerHub.

![image](https://github.com/user-attachments/assets/fc9243ba-21db-4678-a615-b32f5d9cdd20)


* Проверяю на DockerHub.

![image](https://github.com/user-attachments/assets/4067be79-101f-4761-a6b8-89e2ea777eeb)


* Дополнительная проверка. Удаляю образ и заново скачиваю с DockerHub. Запускаю контейнер локально.


![image](https://github.com/user-attachments/assets/ff5dc312-b6df-412e-8473-1b37efabd1eb)
   
![image](https://github.com/user-attachments/assets/0f8f7f5c-2ba0-4ef9-a3ad-e6314c12607e)

![image](https://github.com/user-attachments/assets/b826fc56-125a-4ca2-b88e-e90534b76a2f)

* Деплой в github

git init

git add .

git rm --cached .gitignore 2>/dev/null

git rm --cached *.sh 2>/dev/null

git status

git commit -m 'nginx-app'

git branch -M main

git remote add origin git@github.com:sharvik22/nginx-app.git

git push -f origin main


### `Ожидаемые результаты:`

* Git репозиторий с тестовым приложением и Dockerfile.

# [git@github.com:sharvik22/nginx-app.git](https://github.com/sharvik22/nginx-app.git)


* Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

![image](https://github.com/user-attachments/assets/68ebdb5a-4813-4a87-a730-4abf03011221)

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

* Создаю namespace
kubectl create namespace monitoring

* С помощью helm произожу установку.

helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30090 \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30091 \
  --set alertmanager.service.type=NodePort \
  --set alertmanager.service.nodePort=30092

![image](https://github.com/user-attachments/assets/b302d776-5ca0-42c6-9ec0-065a9d4bea5a)


Я использовал балансировщик Network Load Balancer и NodePort т.к. кластер у меня в локальной сети и не имеет публичного IP, я сделал проброс портов приложения и Grafana

Проверка установки:

### Проверить сервисы

kubectl get svc -n monitoring

![image](https://github.com/user-attachments/assets/0faea3f9-5d4b-494e-94b7-a92fe27693bb)


### Проверить поды

kubectl get pods -n monitoring

![image](https://github.com/user-attachments/assets/35cdb94b-654e-40a7-98af-35df15575149)

kubectl get nodes
kubectl get pods --all-namespaces

![image](https://github.com/user-attachments/assets/e5741564-dd1a-4aa5-acb0-3249f90db6ab)

### Получение пароля Grafana
kubectl -n monitoring get secrets kube-prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

![image](https://github.com/user-attachments/assets/a9625997-dccf-400b-bd07-8cf4ff3314a6)

Открываем адрес балансировщика и логинемся.

### http://158.160.164.63:3000/login  

Данные для входа:

Логин: admin

Пароль: prom-operator

![image](https://github.com/user-attachments/assets/838aaadf-bbb8-4a35-a60a-ceaf351750d3)



# Деплоить тестового приложение.

* Создаю Deployment (nginx-app-deployment.yaml)
* Создаю Service (nginx-app-service.yaml)

Применяю конфигурацию.

* kubectl apply -f nginx-app-deployment.yaml
* kubectl apply -f nginx-app-service.yaml

![image](https://github.com/user-attachments/assets/ee8a6f33-eb44-4cc5-8a84-d17c03a998bd)


Проверка:

kubectl get deployment nginx-app-deployment

![image](https://github.com/user-attachments/assets/7169b6aa-c5b8-4cc4-84e1-1960eb03926d)

Проверить поды (должны быть в состоянии Running)

kubectl get pods -l app=nginx-app

![image](https://github.com/user-attachments/assets/023a75b8-5888-4394-b1a6-f47667022716)


Проверить сервис (должен показать 30080 в NodePort)

kubectl get service nginx-app-service

![image](https://github.com/user-attachments/assets/716d2941-2728-43c6-af96-ae45de82181d)


Проверка балансировщика: 

![image](https://github.com/user-attachments/assets/7c66c552-c4e6-41b4-a026-8aa979303d1f)


Тестовое приложение доступно:

### [http://51.250.43.141](http://158.160.164.63/)

![image](https://github.com/user-attachments/assets/282283f9-d0f8-4f95-9327-a6a2809530e3)


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

* Создал файл для работы с yandex actions

mkdir -p .github/workflows

nano .github/workflows/cidi.yml


* настраиваю секреты в yandex actions

![image](https://github.com/user-attachments/assets/627fe63a-3c0a-429a-adda-b219058f23b5)


`Ожидаемые результаты:`

'Делаю коммит'

![image](https://github.com/user-attachments/assets/fa53618b-5765-4105-84a8-f6f24ba7a8ee)

![image](https://github.com/user-attachments/assets/ce45d428-6a80-445d-8922-6b6e7146ffd4)

![image](https://github.com/user-attachments/assets/d30788b7-4da9-4672-8712-395940638aca)


'Делаю тег'

![image](https://github.com/user-attachments/assets/0692c90e-5da7-40b6-a5c5-1683cc5e869c)

![image](https://github.com/user-attachments/assets/fee4586f-86ab-4dcb-b1d4-019062c9301a)

![image](https://github.com/user-attachments/assets/91ab8911-3b9e-4ee7-b78f-eeb35c346975)

![image](https://github.com/user-attachments/assets/04185bb2-bd5f-4403-95e6-91858e945086)

![image](https://github.com/user-attachments/assets/e13391ec-917f-48d1-8f1c-0736a0467100)


Проверим, какой образ сейчас развёрнут.

![image](https://github.com/user-attachments/assets/e2d492e3-7e5c-4534-849a-028ed128d88a)

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












