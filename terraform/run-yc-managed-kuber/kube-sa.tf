
#создание сервисного аккаунта
resource "yandex_iam_service_account" "sa" {
  folder_id = "${var.folder_id}"
  name        = "kube-sa"
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

resource "yandex_resourcemanager_folder_iam_member" "loadBalancer" {
  # Сервисному аккаунту назначается роль "load-balancer.admin".
  folder_id   = "${var.folder_id}"
  role      = "load-balancer.admin"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
  depends_on  = [yandex_iam_service_account.sa]
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  # Сервисному аккаунту назначается роль "editor".
  folder_id   = "${var.folder_id}"
  role      = "editor"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
  depends_on  = [yandex_iam_service_account.sa]
}
