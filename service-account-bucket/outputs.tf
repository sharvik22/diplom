output "vpc_network" {
  description = "Детали созданной VPC сети"
  value = {
    id      = yandex_vpc_network.vpc_network.id
    name    = yandex_vpc_network.vpc_network.name
    labels  = yandex_vpc_network.vpc_network.labels
    subnets = yandex_vpc_subnet.subnets
  }
  sensitive = false
}

output "subnets_by_zone" {
  description = "Подсети сгруппированные по зонам доступности"
  value = {
    for subnet in yandex_vpc_subnet.subnets : subnet.zone => {
      id     = subnet.id
      name   = subnet.name
      cidr   = subnet.v4_cidr_blocks[0]
      labels = subnet.labels
    }
  }
}

output "subnets_by_name" {
  description = "Подсети сгруппированные по именам"
  value = {
    for name, subnet in yandex_vpc_subnet.subnets : name => {
      id     = subnet.id
      zone   = subnet.zone
      cidr   = subnet.v4_cidr_blocks[0]
      labels = subnet.labels
    }
  }
}


# service-account-bucket/outputs.tf
output "security_group_ids" {
  description = "IDs всех созданных Security Groups"
  value = {
    k8s_main = yandex_vpc_security_group.k8s_main_sg.id
  }
  sensitive = true
}

output "network_summary" {
  description = "Сводная информация о сети для экспорта"
  value = {
    vpc_id = yandex_vpc_network.vpc_network.id
    subnets = {
      for name, subnet in yandex_vpc_subnet.subnets : name => {
        id   = subnet.id
        zone = subnet.zone
      }
    }
  }
}
