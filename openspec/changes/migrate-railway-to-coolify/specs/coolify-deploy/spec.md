## ADDED Requirements

### Requirement: Two-process Compose production configuration
O deploy SHALL fornecer um `compose.prod.yaml` com dois serviços — `web` (Puma) e `worker` (Solid Queue) — compartilhando a mesma imagem de produção, com `restart: unless-stopped`.

#### Scenario: Web serves HTTP
- **WHEN** o serviço `web` é iniciado
- **THEN** Puma atende na porta configurada (padrão 3000) com a aplicação em produção

#### Scenario: Worker processes jobs
- **WHEN** o serviço `worker` é iniciado
- **THEN** o processo Solid Queue consome a fila do PostgreSQL

#### Scenario: Shared image
- **WHEN** qualquer serviço é construído
- **THEN** ambos usam a imagem gerada por `Dockerfile.prod`

### Requirement: Entrypoint prepares database once
O `bin/docker-entrypoint` SHALL rodar `db:prepare` apenas no serviço web, de forma idempotente, antes de executar o comando passado. `db:prepare` cria o banco `migarden` se não existir e aplica migrações. Não altera outros bancos da instância.

#### Scenario: Create database then migrate
- **WHEN** o entrypoint inicia com `RAILS_ENV=production` e o banco em `DATABASE_URL` não existe
- **THEN** o banco é criado e as migrações são aplicadas, depois o comando original é executado

#### Scenario: Migrate before exec
- **WHEN** o entrypoint inicia com `RAILS_ENV=production` e o banco já existe
- **THEN** `bundle exec rails db:prepare` aplica migrações pendentes e, em seguida, o comando original é executado

#### Scenario: Idempotent migrations
- **WHEN** `db:prepare` roda contra um banco já migrado
- **THEN** não ocorre falha (migração é no-op)
