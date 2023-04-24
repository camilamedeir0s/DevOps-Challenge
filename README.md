# Desafio DevOps - AsCan

## Infraestrutura
Para criar a infraestrutura na AWS, foi utilizada a ferramenta de IaC Terraform.

Os comandos utilizados para provisionar a infraestrutura na AWS são:

```bash
terraform init
terraform plan
terraform apply
```

Para excluir os recursos criados, utiliza-se o comando:

```bash
terraform destroy
```

## CI/CD
Para implantar aplicação por meio de CI/CD na infraestrutura criada, foi utilizado GitHub Actions.

A configuração foi feita no arquivo aws.yml. Qualquer push na branch master ativa o workflow.

Para que essa configuração funcione, é necessário inserir as credenciais da AWS em Secrets nas configurações do projeto.

## Monitoramento
Para monitorar a aplicação, foi utilizada a ferramenta [Uptime Kuma](https://github.com/louislam/uptime-kuma).
