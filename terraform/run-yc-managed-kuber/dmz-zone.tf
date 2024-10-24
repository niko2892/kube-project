resource "yandex_dns_zone" "zone1" {
  name        = "kuber-dmz"
  description = "kuber-dmz"

  labels = {
    label1 = "kuber-dmz"
  }

  zone    = "kuber."
  public  = true
}