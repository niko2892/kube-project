
#создание сервисных аккаунтов для s3
resource "yandex_iam_service_account" "terraform-deployer" {
  folder_id = "${var.folder_id}"
  name        = "terraform-deployer"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform-deployer-roles" {
    for_each = toset(var.terraform-deployer-roles)
    folder_id   = "${var.folder_id}"
    role        = each.value
    member      = "serviceAccount:${yandex_iam_service_account.terraform-deployer.id}"
    depends_on  = [yandex_iam_service_account.sa]
}

resource "yandex_iam_service_account" "terraform-state-admin" {
  folder_id   = "${var.folder_id}"
  name        = "terraform-state-admin"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform-state-admin" {
    for_each = toset(var.terraform-state-admin-roles)
    folder_id   = "${var.folder_id}"
    role        = each.value
    member      = "serviceAccount:${yandex_iam_service_account.terraform-state-admin.id}"
    depends_on  = [yandex_iam_service_account.sa]
}