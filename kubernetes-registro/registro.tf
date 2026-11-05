# Credencial de robô só de pull, para o cluster baixar as imagens do registro
resource "restapi_object" "pull" {
  path = "/v1/credentials"
  data = jsonencode({
    name            = "${var.prefixo}-k8s-pull"
    access          = "pull"
    expires_in_days = 365
  })
}

locals {
  robo = jsondecode(restapi_object.pull.api_response)
}
