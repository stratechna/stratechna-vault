# Stratechna Vault

Imagem Docker do Stratechna Vault com branding Stratechna.
Baseada em Paperless-ngx.

## Imagem

    ghcr.io/stratechna/stratechna-vault:latest

## Actualizar para nova versao do Paperless

O GitHub Actions reconstroi a imagem automaticamente todas as segundas-feiras.
Para forcar rebuild: Actions > Build Stratechna Vault > Run workflow

Para actualizar todas as instancias no servidor:

    for dir in /opt/stratechna/vault/clientes/*/; do
      cd "$dir"
      docker compose pull
      docker compose up -d
    done
