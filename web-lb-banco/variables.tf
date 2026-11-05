variable "nuvem" {
  description = "Entrada do clouds.yaml com a credencial de aplicação"
  type        = string
  default     = "estabilis"
}

variable "prefixo" {
  description = "Prefixo dos nomes dos recursos"
  type        = string
  default     = "web"
}

variable "chave_publica" {
  description = "Caminho da chave pública SSH"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "plano_vm" {
  description = "Plano das máquinas web"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "quantidade_vms" {
  description = "Quantidade de máquinas web atrás do balanceador"
  type        = number
  default     = 2
}

variable "senha_banco" {
  description = "Senha do usuário app no banco"
  type        = string
  sensitive   = true
}

variable "plano_banco_id" {
  description = "ID do plano do banco (openstack database flavor show db-s-1vcpu-2gb -c id)"
  type        = string
}
