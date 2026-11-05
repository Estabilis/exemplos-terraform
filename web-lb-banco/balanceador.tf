resource "openstack_lb_loadbalancer_v2" "web" {
  name          = "${var.prefixo}-lb"
  vip_subnet_id = openstack_networking_subnet_v2.app.id
  depends_on    = [openstack_networking_router_interface_v2.app]
}

resource "openstack_lb_listener_v2" "http" {
  name            = "${var.prefixo}-http"
  loadbalancer_id = openstack_lb_loadbalancer_v2.web.id
  protocol        = "HTTP"
  protocol_port   = 80
}

resource "openstack_lb_pool_v2" "web" {
  name        = "${var.prefixo}-pool"
  listener_id = openstack_lb_listener_v2.http.id
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
}

resource "openstack_lb_member_v2" "web" {
  count         = var.quantidade_vms
  name          = openstack_compute_instance_v2.web[count.index].name
  pool_id       = openstack_lb_pool_v2.web.id
  address       = openstack_compute_instance_v2.web[count.index].access_ip_v4
  protocol_port = 80
  subnet_id     = openstack_networking_subnet_v2.app.id
}

resource "openstack_lb_monitor_v2" "http" {
  name        = "${var.prefixo}-hm"
  pool_id     = openstack_lb_pool_v2.web.id
  type        = "HTTP"
  url_path    = "/"
  delay       = 5
  timeout     = 3
  max_retries = 3
}

# IP público na porta do VIP do balanceador
resource "openstack_networking_floatingip_v2" "lb" {
  pool    = "public"
  port_id = openstack_lb_loadbalancer_v2.web.vip_port_id
}
