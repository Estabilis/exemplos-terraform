# Aplicação web com balanceador e banco gerenciado

Terraform completo para a Estabilis Cloud (região `br-sao-1`) que sobe:

- uma rede privada (`10.50.0.0/24`) com sub-rede e roteador com saída para a internet;
- duas máquinas virtuais Ubuntu 24.04 (`s-1vcpu-1gb`, disco de sistema de 10 GB) com o nginx instalado por cloud-init, cada uma respondendo com o próprio nome;
- um Load Balancer com escuta HTTP na porta 80, grupo em round-robin, verificação de saúde e IP público;
- um PostgreSQL 18 gerenciado (`db-s-1vcpu-2gb`, volume de 10 GB), com o banco `app` e o usuário `app`, acessível só a partir das máquinas web (grupo de segurança com origem no grupo `web`);
- grupos de segurança: HTTP de qualquer origem, SSH de qualquer origem e PostgreSQL só das máquinas web.

Tudo com o provider `terraform-provider-openstack/openstack` e os endpoints públicos da região; nenhum provider próprio.

## Antes de começar

1. Uma conta na Estabilis Cloud e uma credencial de aplicação no `~/.config/openstack/clouds.yaml`, na entrada `estabilis` (veja a página Automação da documentação).
2. Terraform 1.6 ou mais novo.
3. Uma chave pública SSH (`~/.ssh/id_ed25519.pub` por padrão).
4. O ID do plano do banco, que sai da CLI do OpenStack com o plugin `python-troveclient`:

   ```sh
   openstack database flavor show db-s-1vcpu-2gb -c id
   ```

## Subir

```sh
cp terraform.tfvars.exemplo terraform.tfvars   # ajuste o plano_banco_id
export TF_VAR_senha_banco='uma senha forte'     # a senha nunca vai em arquivo
terraform init
terraform apply
```

Ao final, `terraform output` mostra o IP público do balanceador, as máquinas e o endereço do banco na rede privada. Em alguns minutos o balanceador responde, alternando entre as duas máquinas:

```sh
curl http://$(terraform output -raw ip_publico_do_balanceador)/
```

A conexão ao banco é feita a partir das máquinas web, com TLS:

```sh
psql 'host=<endereço do banco> user=app dbname=app sslmode=require'
```

## O que é cobrado

As duas máquinas (plano e disco de sistema), o balanceador, o IP público, o banco (plano e volume) e o tráfego de saída. Os valores vigentes estão em https://estabilis.cloud/precos; a cobrança é por hora cheia, e o mês de referência tem 730 horas.

## Destruir

```sh
terraform destroy
```

Apaga tudo o que o exemplo criou, inclusive o banco e os dados dele.

## Ajustes comuns

- `quantidade_vms`: mais máquinas atrás do balanceador (cada uma entra no grupo automaticamente).
- `plano_vm`: outro plano das máquinas (`openstack flavor list`).
- `prefixo`: nome dos recursos, para subir mais de uma cópia no mesmo projeto.
