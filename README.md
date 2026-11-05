# Exemplos de Terraform para a Estabilis Cloud

Projetos completos em Terraform para a Estabilis Cloud (OpenStack, região `br-sao-1`), prontos para clonar, ajustar e subir na sua conta. Cada exemplo foi executado numa conta de cliente comum antes de entrar aqui, usa só o provider `terraform-provider-openstack/openstack` e os endpoints públicos da região.

| Exemplo | O que sobe |
| --- | --- |
| [`web-lb-banco`](web-lb-banco/) | Rede privada, duas máquinas web com nginx, Load Balancer com IP público e PostgreSQL gerenciado com TLS |

## Antes de começar

- Uma credencial de aplicação no `~/.config/openstack/clouds.yaml` (entrada `estabilis`), como explica a documentação em Automação.
- Terraform 1.6 ou mais novo.

Cada pasta tem o seu `README.md` com o passo a passo, o que é cobrado e como destruir. Segredos nunca vão em arquivo: senhas entram por variável de ambiente (`TF_VAR_...`) e o `.gitignore` deixa de fora `terraform.tfvars`, o estado e o `clouds.yaml`.

## Documentação

A documentação da Estabilis Cloud traz cada recurso destes exemplos em Terraform, CLI, API e Python.

## Licença

Apache-2.0: veja o arquivo `LICENSE`.
