terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token ="${var.token}"
  zone = "${var.zone}"
}

#создание сети
resource "yandex_vpc_network" "app-network" {
  folder_id = var.folder_id
  name        = "app-network"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

#Создайте подсети в зонах доступности, где будут созданы кластер Managed Service for Kubernetes и группа узлов.
resource "yandex_vpc_subnet" "app-subnet-a" {
  name           = "kuber-subnet-a"
  v4_cidr_blocks = ["10.0.0.0/26"]
  zone           = "ru-central1-a"
  folder_id      = "${var.folder_id}"
  network_id     = yandex_vpc_network.app-network.id
  depends_on = [yandex_vpc_network.app-network]
}

#создание кластера kubernetes
resource "yandex_kubernetes_cluster" "kuber_cluster" {
 name = "kuber-cluster"
 network_id  = yandex_vpc_network.app-network.id
 folder_id   = "${var.folder_id}"
 master {
  public_ip = true
   master_location {
     zone      = yandex_vpc_subnet.app-subnet-a.zone
     subnet_id = yandex_vpc_subnet.app-subnet-a.id
   }
  #  security_group_ids = [yandex_vpc_security_group.k8s-public-services.id]
 }
 service_account_id      = yandex_iam_service_account.sa.id
 node_service_account_id = yandex_iam_service_account.sa.id
   depends_on = [
     yandex_resourcemanager_folder_iam_member.clusters-agent,
     yandex_resourcemanager_folder_iam_member.images-puller,
     yandex_resourcemanager_folder_iam_member.vpc-public-admin,
     yandex_resourcemanager_folder_iam_member.encrypterDecrypter
   ]
}


#создание группы узлов https://yandex.cloud/ru/docs/managed-kubernetes/operations/node-group/node-group-create#terraform_1
resource "yandex_kubernetes_node_group" "kuber_cluster_workers" {
  cluster_id = yandex_kubernetes_cluster.kuber_cluster.id
  name       = "workers"
  instance_template {
    platform_id = "standard-v1"
    network_acceleration_type = "standard"
    network_interface {
      subnet_ids         = [yandex_vpc_subnet.app-subnet-a.id]
      nat                = true
    }
    container_runtime {
      type = "containerd"
    }
    resources {
      cores         = 2
      core_fraction = 5
      memory        = 4
    }
    boot_disk {
      size = 32
      type = "network-hdd"
    }
  }
  scale_policy {
    fixed_scale {
      size = 2
    }
  }
}


output "kuber_cluster_external_v4_endpoint" {
  value = yandex_kubernetes_cluster.kuber_cluster.master[0].external_v4_endpoint
}

output "kuber_cluster_id" {
  description = "kubernetes cluster id"
  value       = yandex_kubernetes_cluster.kuber_cluster.id
}