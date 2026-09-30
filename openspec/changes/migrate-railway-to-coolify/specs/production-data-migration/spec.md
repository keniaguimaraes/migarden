## ADDED Requirements

### Requirement: Production data migrates without loss
O sistema SHALL preservar, durante a migração Railway → Coolify, todos os dados reais (`users`, `plants`, `care_parameters`, `care_logs`) e os metadados de foto (`active_storage_attachments`, `active_storage_blobs`, `active_storage_variant_records`) que apontam para objetos no Cloudflare R2.

#### Scenario: Dump preserva schema e dados
- **WHEN** o dump `pg_dump --format=custom --no-owner --no-privileges` é executado contra o PostgreSQL do Railway
- **THEN** o arquivo resultante contém schema e dados de todas as tabelas de aplicação e de Active Storage

#### Scenario: Restore populates destination database
- **WHEN** `pg_restore --clean --if-exists` é executado contra o PostgreSQL do Coolify
- **THEN** as contagens de `users`, `plants`, `care_logs` e `active_storage_blobs` no destino são iguais às do Railway

#### Scenario: Photo references remain valid
- **WHEN** as variáveis `R2_*` no Coolify apontam para o mesmo bucket R2
- **THEN** as fotos continuam acessíveis sem re-upload, pois `active_storage_blobs` preserva as keys originais

### Requirement: Solid Queue history is cleared on migration
O sistema SHALL remover o histórico de jobs em voo do Solid Queue após o restore, mantendo o reagendamento automático do lembrete.

#### Scenario: Job tables truncated
- **WHEN** as tabelas `solid_queue_*` são truncadas após o restore
- **THEN** nenhum job, processo ou execução antiga do Railway permanece no destino

#### Scenario: Reminder reschedules on boot
- **WHEN** o serviço web boota pela primeira vez no Coolify
- **THEN** o initializer agenda um novo `PlantReminderJob` para o próximo 08h, sem duplicatas

## ADDED Requirements

### Requirement: Deployment runs on Coolify
A aplicação SHALL ser implantável no Coolify via Docker Compose com dois processos (web e worker) e migração automática no boot.

#### Scenario: Automated migration on boot
- **WHEN** o serviço web inicia via entrypoint
- **THEN** `db:prepare` é executado antes do Puma subir

#### Scenario: Worker runs without double migration
- **WHEN** o serviço worker inicia
- **THEN** nenhuma migração é executada (apenas o Solid Queue inicia), evitando corrida com o web

#### Scenario: TLS trusted to proxy
- **WHEN** o tráfego chega ao Puma atrás do proxy Coolify
- **THEN** a aplicação trata a conexão como HTTPS (`force_ssl`) e `X-Forwarded-Proto` é honrado
