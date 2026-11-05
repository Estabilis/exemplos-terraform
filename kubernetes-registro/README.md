# Cluster Kubernetes com o Container Registry do projeto

Terraform completo para a Estabilis Cloud (região `br-sao-1`) que sobe:

- um cluster Kubernetes gerenciado a partir do template `k8s-v1.37.1-managed` (plano de controle hospedado pela plataforma; você paga só os nós), com o número de nós que escolher;
- uma credencial de robô do Container Registry do projeto, só de pull, para o cluster baixar imagens;
- as saídas que você usa em seguida: o endereço da API, o `kubeconfig`, o usuário e o segredo do robô e o prefixo das imagens do projeto no registro.

O cluster é criado pelo provider `terraform-provider-openstack/openstack`; a credencial do registro, pelo provider genérico `Mastercard/restapi`, com o token do provider OpenStack (o token nunca vai para os arquivos).

Depois, um manifesto de exemplo (`app.yaml`) publica o nginx a partir do cache do Docker Hub do seu registro, com um `Service` do tipo `LoadBalancer` que ganha IP público.

## Antes de começar

1. Uma conta na Estabilis Cloud e uma credencial de aplicação no `~/.config/openstack/clouds.yaml`, na entrada `estabilis` (veja a página Automação da documentação).
2. Terraform 1.6 ou mais novo, `kubectl` e `jq`.
3. Um par de chaves cadastrado no projeto (`openstack keypair list`), para acesso SSH aos nós.

## Subir

```sh
cp terraform.tfvars.exemplo terraform.tfvars
# ajuste a chave, o número de nós e os IPs que podem usar a API
terraform init
terraform apply
```

O cluster leva alguns minutos para ficar pronto. O `kubeconfig` sai como mapa sensível; o campo `raw_config` é o arquivo:

```sh
terraform output -json kubeconfig | jq -r .raw_config > kubeconfig
chmod 600 kubeconfig
export KUBECONFIG=$PWD/kubeconfig
kubectl get nodes
```

## Publicar uma aplicação a partir do registro

O segredo de pull usa o robô criado pelo Terraform; o prefixo do registro entra no manifesto no lugar de `<prefixo do registro>`:

```sh
kubectl create secret docker-registry registro \
  --docker-server=registry.br-sao-1.onestabilis.com \
  --docker-username="$(terraform output -raw registro_usuario)" \
  --docker-password="$(terraform output -raw registro_segredo)"

sed "s#<prefixo do registro>#$(terraform output -raw registro_prefixo)#" app.yaml \
  | kubectl apply -f -

kubectl get svc web          # EXTERNAL-IP: o IP público do balanceador
curl http://<EXTERNAL-IP>/
```

A imagem `nginx:1.27` é baixada pelo cache do Docker Hub do seu registro (`<prefixo do registro>-dockerhub/library/nginx:1.27`); imagens suas usam `<prefixo do registro>/<imagem>:<tag>`.

## O que é cobrado

Os nós do cluster (máquinas virtuais com o disco de sistema), o balanceador e o IP público do `Service`, o tráfego de saída e o espaço usado no registro. Os valores vigentes estão em https://estabilis.cloud/precos; a cobrança é por hora cheia, e o mês de referência tem 730 horas.

## Destruir

Apague primeiro os objetos do Kubernetes que criaram balanceador e volumes, depois o cluster:

```sh
kubectl delete -f app.yaml
terraform destroy
```

## Ajustes comuns

- `nos`: número de nós de trabalho.
- `cidrs_api`: IPs ou redes (CIDR) autorizados a chegar à API do cluster, por exemplo `["203.0.113.10/32"]`; o template exige essa escolha na criação.
- `template`: `k8s-v1.37.1-dedicated` para o plano de controle em máquinas do seu projeto.
- `prefixo`: nome dos recursos, para subir mais de uma cópia no mesmo projeto.
