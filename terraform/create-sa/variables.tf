variable "terraform-deployer-roles" {
  type = list(string)
  description = "роли для сервисного аккаунта terraform-deployer"
  default = ["alb.editor","certificate-manager.admin","container-registry.admin","compute.admin","dns.admin",
  "functions.editor","k8s.admin","k8s.cluster-api.cluster-admin","k8s.clusters.agent","kms.admin","load-balancer.privateAdmin",
  "logging.admin","mdb.admin","monitoring.admin","resource-manager.viewer","storage.admin",
  "viewer","vpc.gateways.user","vpc.privateAdmin","vpc.securityGroups.user","websql.admin","ydb.admin"]
}
# +,"resource-manager.clouds.member" ?

variable "terraform-state-admin-roles" {
  type = list(string)
  description = "роли для сервисного аккаунта terraform-state-admin"
  default = ["storage.uploader","kms.keys.encrypterDecrypter","storage.viewer","ydb.editor"]
}

variable "kube-sa-roles" {
  type = list(string)
  description = "роли для сервисного аккаунта terraform-state-admin"
  default = ["container-registry.images.puller","k8s.clusters.agent","vpc.publicAdmin","load-balancer.admin","editor"]
}

variable "cloud_catalog_title" {
  type = string
  description = "Название каталога"
  default = "kuber"
}

variable "token" {
  type = string
  description = "токен"
  default = "y0_AgAAAAA8mPYyAATuwQAAAAEM8sX_AAA-Os8HL3pBubfzigMAjhgQe7df5g"
}

variable "zone" {
  type = string
  description = "зона доступности"
  default = "ru-central1-a"
}

variable "folder_id" {
  type = string
  description = "id каталога"
  default = "b1ga0tqq6d44s8ag72uu"
}

variable "cloud_id" {
  type = string
  description = "id облака"
  default = "b1g9c5t8oc2sk6jadhqm"
}
