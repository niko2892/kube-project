variable "cloud_catalog_title" {
  type = string
  description = "Название каталога"
}

variable "token" {
  type = string
  description = "токен"
}

variable "cloud_id" {
  type = string
  description = "id облака"
}

variable "folder_id" {
  type = string
  description = "id каталога"
}

variable "zone" {
  type = string
  description = "зона доступности"
}


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
  folder_id = "${var.folder_id}"
}


#создание сети
resource "yandex_vpc_network" "app-network" {
  name        = "app-network"
  folder_id = "${var.folder_id}"
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


#создание сервисного аккаунта
resource "yandex_iam_service_account" "sa" {
  name        = "kube-sa"
  folder_id   = "${var.folder_id}"
}


#назначение ролей сервисному аккаунту:
resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  folder_id   = "${var.folder_id}"
  role        = "container-registry.images.puller"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
  depends_on  = [yandex_iam_service_account.sa]
}

resource "yandex_resourcemanager_folder_iam_member" "clusters-agent" {
  folder_id   = "${var.folder_id}"
  role        = "k8s.clusters.agent"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
  depends_on  = [yandex_iam_service_account.sa]
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id   = "${var.folder_id}"
  role      = "vpc.publicAdmin"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
  depends_on  = [yandex_iam_service_account.sa]
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  # Сервисному аккаунту назначается роль "kms.keys.encrypterDecrypter".
  folder_id   = "${var.folder_id}"
  role      = "kms.keys.encrypterDecrypter"
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
    }
    container_runtime {
      type = "containerd"
    }
    resources {
      cores         = 2
      core_fraction = 5
      memory        = 2
    }
    boot_disk {
      size = 32
      type = "network-hdd"
    }
  }
  scale_policy {
    fixed_scale {
      size = 1
    }
  }
}


output "kuber_cluster_external_v4_endpoint" {
  value = yandex_kubernetes_cluster.kuber_cluster.master[0].external_v4_endpoint
}

output "kuber_cluster_public_ip" {
  value = yandex_kubernetes_cluster.kuber_cluster.master[0].public_ip
}
