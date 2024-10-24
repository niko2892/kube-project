resource "yandex_dns_zone" "zone1" {
  name        = "kuber-dns"
  description = "kuber-dns"
  folder_id = var.folder_id
  labels = {
    label1 = "kuber-dns"
  }

  # zone    = "kuber.tech."
  zone    = "studygroup.tech"
  public  = true
}