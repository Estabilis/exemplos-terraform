output "ip_publico_do_balanceador" {
  value = openstack_networking_floatingip_v2.lb.address
}

output "maquinas" {
  value = { for vm in openstack_compute_instance_v2.web : vm.name => vm.access_ip_v4 }
}

output "endereco_do_banco" {
  value = openstack_db_instance_v1.pg.addresses
}
