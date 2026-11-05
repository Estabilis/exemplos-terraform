# Rede privada, sub-rede e roteador com saída para a internet
resource "openstack_networking_network_v2" "app" {
  name = "${var.prefixo}-rede"
}

resource "openstack_networking_subnet_v2" "app" {
  name            = "${var.prefixo}-sub-rede"
  network_id      = openstack_networking_network_v2.app.id
  cidr            = "10.50.0.0/24"
  ip_version      = 4
  dns_nameservers = ["187.109.72.60", "187.109.72.61"]
}

data "openstack_networking_network_v2" "publica" {
  name = "public"
}

resource "openstack_networking_router_v2" "app" {
  name                = "${var.prefixo}-roteador"
  external_network_id = data.openstack_networking_network_v2.publica.id
}

resource "openstack_networking_router_interface_v2" "app" {
  router_id = openstack_networking_router_v2.app.id
  subnet_id = openstack_networking_subnet_v2.app.id
}

# Grupos de segurança: HTTP vindo do balanceador e SSH de qualquer origem
resource "openstack_networking_secgroup_v2" "web" {
  name        = "${var.prefixo}-web"
  description = "HTTP na porta 80"
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  security_group_id = openstack_networking_secgroup_v2.web.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_v2" "ssh" {
  name        = "${var.prefixo}-ssh"
  description = "SSH"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  security_group_id = openstack_networking_secgroup_v2.ssh.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

# Banco: só as máquinas do grupo web chegam à porta 5432
resource "openstack_networking_secgroup_v2" "banco" {
  name        = "${var.prefixo}-banco"
  description = "PostgreSQL a partir das máquinas web"
}

resource "openstack_networking_secgroup_rule_v2" "banco" {
  security_group_id = openstack_networking_secgroup_v2.banco.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_group_id   = openstack_networking_secgroup_v2.web.id
}
