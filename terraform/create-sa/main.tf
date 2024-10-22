terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  # backend "s3" {
  #   endpoint          = "https://storage.yandexcloud.net"
  #   dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1g51q1dos9of1b1ig5s/etnntu1sheicvm8un255"
  #   bucket            = "tfstate-default-trainee"
  #   region            = "ru-central1"
  #   key               = "example-remote-state/terraform.tfstate"

  #   dynamodb_table    = "tfstates-locks"

  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  #   skip_requesting_account_id  = true
  #   skip_s3_checksum            = true
  # }
}

provider "yandex" {
  token ="${var.token}"
  zone  = "${var.zone}"
  folder_id = "${var.folder_id}"
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

#создание сервисных аккаунтов для s3
resource "yandex_iam_service_account" "terraform-deployer" {
  name        = "terraform-deployer"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform-deployer-roles" {
    for_each    = toset(var.terraform-deployer-roles)
    folder_id   = "${var.folder_id}"
    role        = each.value
    member      = "serviceAccount:${yandex_iam_service_account.terraform-deployer.id}"
    depends_on  = [yandex_iam_service_account.sa]
}

resource "yandex_iam_service_account" "terraform-state-admin" {
  name        = "terraform-state-admin"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform-state-admin" {
    for_each    = toset(var.terraform-state-admin-roles)
    folder_id   = "${var.folder_id}"
    role        = each.value
    member      = "serviceAccount:${yandex_iam_service_account.terraform-state-admin.id}"
    depends_on  = [yandex_iam_service_account.sa]
}
