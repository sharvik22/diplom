resource "yandex_vpc_network" "vpc_network" {
  name        = var.vpc_name
  description = "VPC сеть для Kubernetes кластера"
  labels = {
    environment = "production"
    terraform   = "true"
    project     = "kubernetes"
  }
}

resource "yandex_vpc_subnet" "subnets" {
  for_each = var.subnets

  name           = "${var.vpc_name}-${each.key}"
  description    = "Подсеть для ${each.key} в зоне ${each.value.zone}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.vpc_network.id
  v4_cidr_blocks = [each.value.cidr]
  labels         = merge(each.value.labels, { name = each.key })
}
