variable "terraform-deployer-roles" {
  type = list(string)
  description = "роли для сервисного аккаунта terraform-deployer"
  default = ["alb.editor","certificate-manager.admin","container-registry.admin","compute.admin","dns.admin",
  "functions.editor","k8s.admin","k8s.cluster-api.cluster-admin","k8s.clusters.agent","kms.admin","load-balancer.privateAdmin",
  "logging.admin","mdb.admin","monitoring.admin","resource-manager.clouds.member","resource-manager.viewer","storage.admin",
  "viewer","vpc.gateways.user","vpc.privateAdmin","vpc.securityGroups.user","websql.admin","ydb.admin"]
}

variable "terraform-state-admin-roles" {
  type = list(string)
  description = "роли для сервисного аккаунта terraform-state-admin"
  default = ["trainee","storage.uploader","kms.keys.encrypterDecrypter","storage.viewer","ydb.editor"]
}
