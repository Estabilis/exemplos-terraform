resource "openstack_db_instance_v1" "pg" {
  name        = "${var.prefixo}-pg"
  flavor_id   = var.plano_banco_id
  size        = 10
  volume_type = "fc"

  datastore {
    type    = "postgresql"
    version = "18"
  }

  network {
    uuid = openstack_networking_network_v2.app.id
  }

  database {
    name = "app"
  }

  user {
    name      = "app"
    password  = var.senha_banco
    databases = ["app"]
  }

  depends_on = [openstack_networking_router_interface_v2.app]
}
