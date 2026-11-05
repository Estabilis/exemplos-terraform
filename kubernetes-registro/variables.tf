variable "nuvem" {
  description = "Entrada do clouds.yaml com a credencial de aplicação"
  type        = string
  default     = "estabilis"
}

variable "prefixo" {
  description = "Prefixo dos nomes dos recursos"
  type        = string
  default     = "app"
}

variable "template" {
  description = "Template do cluster (openstack coe cluster template list)"
  type        = string
  default     = "k8s-v1.37.1-managed"
}

variable "nos" {
  description = "Quantidade de nós de trabalho"
  type        = number
  default     = 1
}

variable "chave" {
  description = "Nome do par de chaves no projeto, para acesso SSH aos nós"
  type        = string
}
