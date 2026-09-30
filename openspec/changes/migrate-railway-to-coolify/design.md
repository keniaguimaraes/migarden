## Context

migarden hoje está em produção no Railway: serviços `web` (Puma) e `worker` (Solid Queue), PostgreSQL provisionado (`postgres-volume`), fotos no Cloudflare R2. O `railway.json` roda `db:migrate` como `preDeployCommand`. O `bin/docker-entrypoint` está vazio (nunca usado). Não existe `compose.prod.yaml`; só `docker-compose.yml` de dev.

O sapafit já roda em Coolify (VPS própria) com tipo de deploy Docker Compose e PostgreSQL gerenciado fora do compose. Esta migração replica esse padrão.

Dados verificados no Railway (Postgres público acessível): `users=1`, `plants=16`, `care_parameters=48`, `care_logs=109`, `active_storage_blobs=55`, `solid_queue_jobs=436`.

Jobs: o `PlantReminderJob` usa Solid Queue e se auto-reagenda para as 08h (bootstrap no initializer `plant_reminder_schedule.rb`). Não usa Redis. `config/active_job.queue_adapter = :solid_queue`.

## Goals / Non-Goals

**Goals:**
- Migrar PostgreSQL do Railway → Coolify sem perda de dados reais nem de fotos.
- Deploy funcional no Coolify: web (Puma) + worker (Solid Queue).
- Migração automática no boot (substitui o `preDeployCommand` do Railway).
- TLS correto atrás do proxy Coolify.

**Non-Goals:**
- Não migrar arquivos de fotos (ficam no R2).
- Não trocar o backend de jobs (mantém Solid Queue; Redis não é introduzido).
- Não mudar comportamento de aplicação (nenhuma spec de domínio alterada).
- Não fazer zero-downtime (MVP com 1 usuário; janela curta aceitável).

## Decisions

1. **Dump no R2 bucket, não no disco**: usar o `DATABASE_PUBLIC_URL` do Postgres do Railway como destino do `pg_dump`. O `format=custom` + `--no-owner --no-privileges` evita conflito de role entre o owner `railway` e o owner do novo Postgres. (Alternativa considerada: `railway connect postgres` via proxy — mas URL pública já funciona, eliminando tunel.)

2. **Manter R2 como está**: `active_storage_blobs` guarda as keys que apontam para o bucket atual. Reusar as mesmas `R2_*` no Coolify evita re-upload e reescrita de 55 blobs. (Alternativa: trocar bucket/conta → re-upload manual, rejeitada.)

3. **Restore com `--clean --if-exists`**: permite re-executar o restore com segurança contra banco já populado. Pré-requisito: conferir a URL do destino antes de rodar (destrutivo se apontar pro banco errado).

4. **Truncar Solid Queue pós-restore**: jobs em voo do Railway (436) não têm sentido no novo host. O initializer reagenda o lembrete no primeiro boot, então o truncate é seguro. (Alternativa: levar histórico → lixo e possíveis heartbeats fantasma, rejeitada.)

5. **`bin/docker-entrypoint` com `db:prepare`**: replica o `preDeployCommand` do Railway e ainda cria o banco `migarden` se não existir (não precisa `CREATE DATABASE` na mão). `Dockerfile.prod` usa `ENTRYPOINT ["bin/docker-entrypoint"]` + `CMD` com o Puma. `worker` usa o mesmo entrypoint com `CMD` diferente e **não** roda `db:prepare`.

6. **`force_ssl` + proxy headers**: Coolify termina TLS e faz proxy HTTP. Habilitar `config.force_ssl = true` e confiar `X-Forwarded-Proto` (Puma já recebe `--proxy-headers`; garantir `Rails.application.config.assume_ssl` se necessário) para cookie de sessão seguro.

7. **2 serviços no compose.prod.yaml, mesma imagem**: `web` e `worker` compartilham a imagem do `Dockerfile.prod`. PostgreSQL fica fora do compose (gerenciado pelo Coolify), igual sapafit.

## Migration Plan

1. Reusar `shared-postgres` (projeto Coolify `infrastructure`). `DATABASE_URL` com `/migarden`. O boot do web (`db:prepare`) cria o banco se faltar.
2. Parar `web`/`worker` no Railway (janela curta) ou dump ao vivo (1 usuário).
3. `pg_dump` do `DATABASE_PUBLIC_URL` do Railway → `migarden.dump`.
4. Criar `compose.prod.yaml`, `bin/docker-entrypoint`, ajustar `Dockerfile.prod`, `production.rb`.
5. Deploy no Coolify (recurso Docker Compose apontando para `compose.prod.yaml`); configurar env vars no painel.
6. `pg_restore` no Postgres do Coolify (com `--clean --if-exists`).
7. Truncar tabelas `solid_queue_*`.
8. Validar: login, plantas com foto, `SolidQueue::Process` ativo, lembrete agendado em `solid_queue_scheduled_executions`.
9. Cutover de domínio + TLS.

**Rollback**: manter projeto Railway intacto até cutover. Reverter = apontar DNS de volta e confirmar dados (dump preservado). Nenhuma mudança destrutiva no Railway até validação completa.

## Risks / Trade-offs

- [Perda de dados] Restore em banco errado → conferir URL de destino; usar `--if-exists`; manter dump.
- [App sobe com schema antigo] entrypoint sem `db:migrate` no worker e com migração dupla quando web e worker bootam juntos → rodar `db:migrate` apenas no serviço web; worker apenas inicia solid_queue.
- [Sessão expira] `SECRET_KEY_BASE` novo → re-login; aceitável.
- [Proxy headers] `X-Forwarded-Proto` não repassado → cookie sem Secure e redirect http/https quebrado → configurar proxy headers/assume_ssl.
- [R2 sem credenciais corretas] fotos quebram → validar env `R2_*` no passo 6.
- [Redis órfão] `.env.example` menciona Redis mas não é usado → remover referência em limpeza futura; não bloqueia esta migração.

## Open Questions

- Internal URL do `shared-postgres` (projeto `infrastructure`) com database `migarden`.
- Domínio final e se o proxy Coolify está configurado para terminá-lo.
