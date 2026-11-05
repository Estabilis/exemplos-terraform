output "api" {
  value = openstack_containerinfra_cluster_v1.app.api_address
}

output "kubeconfig" {
  value     = openstack_containerinfra_cluster_v1.app.kubeconfig
  sensitive = true
}

output "registro_usuario" {
  value = local.robo.username
}

output "registro_segredo" {
  value     = local.robo.secret
  sensitive = true
}

# O ID do projeto é o prefixo das imagens no registro
output "registro_prefixo" {
  value = "registry.br-sao-1.onestabilis.com/${data.openstack_identity_auth_scope_v3.sessao.project_id}"
}
