data "openstack_images_image_v2" "ubuntu" {
  name = "ubuntu-24.04"
}

resource "openstack_compute_keypair_v2" "chave" {
  name       = "${var.prefixo}-chave"
  public_key = file(var.chave_publica)
}

# Uma porta por máquina, com os grupos de segurança
resource "openstack_networking_port_v2" "web" {
  count      = var.quantidade_vms
  name       = "${var.prefixo}-${count.index + 1}"
  network_id = openstack_networking_network_v2.app.id
  security_group_ids = [
    openstack_networking_secgroup_v2.web.id,
    openstack_networking_secgroup_v2.ssh.id,
  ]
  depends_on = [openstack_networking_subnet_v2.app]
}

# Instala o nginx e publica o nome da máquina
locals {
  cloud_init = <<-EOT
    #cloud-config
    package_update: true
    packages: [nginx]
    runcmd:
      - echo "ola de $(hostname)" > /var/www/html/index.html
  EOT
}

resource "openstack_compute_instance_v2" "web" {
  count       = var.quantidade_vms
  name        = "${var.prefixo}-${count.index + 1}"
  flavor_name = var.plano_vm
  key_pair    = openstack_compute_keypair_v2.chave.name
  user_data   = local.cloud_init

  # disco de sistema: volume de 10 GB, apagado junto com a máquina
  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 10
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.web[count.index].id
  }
}
