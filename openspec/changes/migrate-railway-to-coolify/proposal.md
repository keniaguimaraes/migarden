## Why

migarden hoje roda no Railway (web + worker + PostgreSQL). O objetivo é migrar para VPS própria com Coolify, seguindo o padrão já validado no projeto sapafit. Ganho: custo previsível, ambiente único sob controle próprio, eliminar dependência do PaaS.

## What Changes

- Migrar dados do PostgreSQL do Railway para o PostgreSQL gerenciado pelo Coolify (schema + dados).
- Manter fotos no Cloudflare R2 (externo) — apenas reusar as credenciais `R2_*` no Coolify; nenhum arquivo é movido.
- Provisionar deploy tipo Docker Compose no Coolify com dois serviços: `web` (Puma) e `worker` (Solid Queue).
- Criar `compose.prod.yaml` (não existe hoje; só há `docker-compose.yml` de dev).
- Criar `bin/docker-entrypoint` real que roda `db:migrate` antes de subir o processo (hoje o arquivo está vazio).
- Ajustar `Dockerfile.prod` para usar o entrypoint (migração automática, substituindo o `preDeployCommand` do `railway.json`).
- Truncar jobs em voo do Solid Queue após o restore (histórico do Railway não faz sentido no novo host).
- Ajustar `production.rb`: habilitar `force_ssl` para terminação TLS no proxy do Coolify.
- **BREAKING**: `SECRET_KEY_BASE` muda → sessões existentes expiram; usuário faz novo login (sem perda de dados).

## Capabilities

### New Capabilities

- `production-data-migration`: Procedimento de dump/restore do PostgreSQL Railway → Coolify preservando dados reais (`users`, `plants`, `care_parameters`, `care_logs`) e os metadados do Active Storage (`active_storage_*`) que apontam para fotos no R2, com limpeza do histórico do Solid Queue e validação pós-restore.
- `coolify-deploy`: Configuração de deploy autônomo no Coolify vias `compose.prod.yaml` + `bin/docker-entrypoint`, com dois processos (web Puma e worker Solid Queue), migração automática no boot e TLS confiado a proxy.

### Modified Capabilities

None — nenhuma especificação de comportamento de aplicação muda.

## Impact

- `compose.prod.yaml` — novo (serviços web + worker).
- `bin/docker-entrypoint` — novo conteúdo (hoje vazio); `chmod +x`.
- `Dockerfile.prod` — usar `ENTRYPOINT bin/docker-entrypoint`.
- `config/environments/production.rb` — `config.force_ssl = true`.
- `railway.json` — obsoleto pós-migração (manter até cutover concluído).
- Infra: PostgreSQL gerenciado Coolify (novo), Cloudflare R2 (inalterado), domínio + TLS no proxy Coolify.
- `REDIS_URL` — removível: ActionCable não é montado e jobs usam Solid Queue (PostgreSQL). Não bloqueia a migração.
