## 1. Dump dos dados do Railway

- [ ] 1.1 Executar `pg_dump` contra `DATABASE_PUBLIC_URL` do Railway com `--format=custom --no-owner --no-privileges`, gerando `migarden.dump`
- [ ] 1.2 Conferir tamanho/validade do dump (`pg_restore --list migarden.dump` lista objetos sem erro)
- [ ] 1.3 Guardar o dump fora do repo (ex: `~/Desktop/migarden.dump`)

## 2. Infra de deploy Coolify

- [ ] 2.1 Criar `compose.prod.yaml` com serviços `web` (Puma) e `worker` (Solid Queue), mesma imagem, `restart: unless-stopped`
- [ ] 2.2 Criar `bin/docker-entrypoint` executando `db:prepare` (cria banco se faltar + migrate) antes de `exec "$@"` e dar `chmod +x`
- [ ] 2.3 Ajustar `Dockerfile.prod` para usar `ENTRYPOINT ["bin/docker-entrypoint"]` e `CMD` com Puma
- [ ] 2.4 Habilitar `config.force_ssl = true` em `config/environments/production.rb`

## 3. Provisionamento no Coolify

- [ ] 3.1 Copiar internal URL do `shared-postgres` (projeto `infrastructure`) e trocar o database name para `/migarden` (`db:prepare` cria o banco no primeiro boot)
- [ ] 3.2 Criar projeto Coolify `migarden` + recurso Docker Compose apontando para o repo + `compose.prod.yaml`
- [ ] 3.3 Configurar env vars no painel: `DATABASE_URL`, `SECRET_KEY_BASE`, `RAILS_SERVE_STATIC_FILES`, `RAILS_LOG_TO_STDOUT`, `ACTIVE_STORAGE_SERVICE`, `R2_*`, `SENTRY_DSN` (opcional), `LOKI_*` (opcional)

## 4. Restore dos dados

- [ ] 4.1 Executar `pg_restore --no-owner --no-privileges --clean --if-exists` no PostgreSQL do Coolify
- [ ] 4.2 Verificar contagens (`users`, `plants`, `care_logs`, `active_storage_blobs`) idênticas ao Railway
- [ ] 4.3 Truncar todas as tabelas `solid_queue_*` com `RESTART IDENTITY`

## 5. Validação pós-migração

- [ ] 5.1 Confirmar login funciona (re-login esperado por causa do novo `SECRET_KEY_BASE`)
- [ ] 5.2 Confirmar fotos carregando (env `R2_*` corretos)
- [ ] 5.3 Confirmar `SolidQueue::Process` ativo (worker processando)
- [ ] 5.4 Confirmar `PlantReminderJob` agendado em `solid_queue_scheduled_executions`

## 6. Cutover

- [ ] 6.1 Apontar domínio final para o proxy Coolify e validar TLS
- [ ] 6.2 Confirmar estabilidade e, após validação, desativar recursos do Railway
- [ ] 6.3 Remover `railway.json` e referências obsoletas (incl. `REDIS_URL` no `.env.example`)
