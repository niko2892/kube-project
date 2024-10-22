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

#создание каталога в облаке
resource "yandex_resourcemanager_folder" "app-folder" {
    cloud_id    = "${var.cloud_id}"
    name        = "${var.cloud_catalog_title}"
}

#вывод id облака
output "folder_id" {
  value = yandex_resourcemanager_folder.app-folder.id
}