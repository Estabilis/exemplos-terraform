terraform {
  required_version = ">= 1.6"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 3.0"
    }
  }
}

provider "openstack" {
  cloud = var.nuvem
}

# Token do provider OpenStack, reaproveitado na API do Container Registry
data "openstack_identity_auth_scope_v3" "sessao" {
  name         = "registro"
  set_token_id = true
}

provider "restapi" {
  uri                  = "https://container-registry.br-sao-1.api.onestabilis.com"
  write_returns_object = true
  id_attribute         = "id"
  headers = {
    "X-Auth-Token" = data.openstack_identity_auth_scope_v3.sessao.token_id
    "Content-Type" = "application/json"
  }
}
