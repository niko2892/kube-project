#создание каталога в облаке
resource "yandex_resourcemanager_folder" "app-folder" {
    cloud_id    = "${var.cloud_id}"
    name        = "${var.cloud_catalog_title}"
}