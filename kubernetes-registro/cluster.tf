# O template pelo nome: o ID muda quando a plataforma o atualiza
data "openstack_containerinfra_clustertemplate_v1" "modelo" {
  name = var.template
}

resource "openstack_containerinfra_cluster_v1" "app" {
  name                = "${var.prefixo}-k8s"
  cluster_template_id = data.openstack_containerinfra_clustertemplate_v1.modelo.id
  node_count          = var.nos
  keypair             = var.chave
  # mantém os labels do template e acrescenta o acesso à API
  merge_labels        = true
  labels = {
    estabilis_api_access    = "internet"
    master_lb_allowed_cidrs = join(",", var.cidrs_api)
  }
}
