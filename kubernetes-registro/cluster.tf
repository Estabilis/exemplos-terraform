# O template pelo nome: o ID muda quando a plataforma o atualiza
data "openstack_containerinfra_clustertemplate_v1" "modelo" {
  name = var.template
}

resource "openstack_containerinfra_cluster_v1" "app" {
  name                = "${var.prefixo}-k8s"
  cluster_template_id = data.openstack_containerinfra_clustertemplate_v1.modelo.id
  node_count          = var.nos
  keypair             = var.chave
}
