terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "kube-project-terraform-state"
    region = "ru-central1"
    key    = "kuber-state/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
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
  depends_on     = [yandex_vpc_network.app-network]
}

#создание сервисного аккаунта для kubernetes
resource "yandex_iam_service_account" "sa" {
  folder_id   = "${var.folder_id}"
  name        = "kube-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "kube-sa-roles" {
    for_each    = toset(var.kube-sa-roles)
    folder_id   = "${var.folder_id}"
    role        = each.value
    member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
    depends_on  = [yandex_iam_service_account.sa]
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

  #  security_group_ids = [
  #     yandex_vpc_security_group.k8s-main-sg.id,
  #     yandex_vpc_security_group.k8s-master-whitelist.id
  #   ]
 }
 service_account_id      = yandex_iam_service_account.sa.id
 node_service_account_id = yandex_iam_service_account.sa.id
   depends_on = [
     yandex_resourcemanager_folder_iam_member.kube-sa-roles
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
      nat                = true
      subnet_ids         = [yandex_vpc_subnet.app-subnet-a.id]
      # security_group_ids = [
      #   yandex_vpc_security_group.k8s-main-sg.id,
      #   yandex_vpc_security_group.k8s-nodes-ssh-access.id,
      #   yandex_vpc_security_group.k8s-public-services.id
      # ]
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
      size = 3
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