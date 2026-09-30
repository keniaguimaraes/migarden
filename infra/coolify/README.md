# Coolify

Deploy auto-hospedado na VPS Contabo. Replica o padrão do sapafit.

## Organização no painel

```
Projects
├── Sapafit          → app sapafit (1 env, 1 resource)
├── infrastructure   → shared-postgres (Database, Running, localhost)
└── migarden         → web + worker (criar)
```

Postgres **não** entra no compose. Usa o recurso já existente `shared-postgres` no projeto `infrastructure`.

## Bancos na instância compartilhada

Uma instância, um banco por app:

```
shared-postgres
├── sapafit     (já existe)
└── migarden    (criado no primeiro boot via db:prepare)
```

Não cria banco na mão. `DATABASE_URL` com `/migarden` no fim; o entrypoint do web roda `db:prepare` e cria o banco se não existir. sapafit não é tocado.

Host/user/senha = os do `shared-postgres`. Só muda o nome no fim da URL:

```text
postgres://USER:PASS@HOST:5432/migarden
```

Internal URL (containers na mesma VPS): copiar no painel do `shared-postgres` e trocar o database name pra `migarden`.

## Como o deploy é feito

Tipo **Docker Compose**, arquivo `compose.prod.yaml`.

| Serviço | Como roda |
| --- | --- |
| PostgreSQL | Recurso `shared-postgres` no projeto `infrastructure`. Fora do compose. |
| web (Puma) | `Dockerfile.prod`. Entrypoint roda `db:prepare` (cria banco se faltar + migrate) e sobe Puma na porta 3000. |
| worker (Solid Queue) | Mesma imagem. Entrypoint **não** migra; só `rake solid_queue:start`. |

## Variáveis no painel (projeto migarden)

Referência: `.env.prod.example`.

Obrigatórias:

- `DATABASE_URL` — internal URL do `shared-postgres` com database `migarden`
- `SECRET_KEY_BASE` — gerar com `openssl rand -hex 64`

Fotos (reusar as do Railway/R2, sem re-upload):

- `R2_ENDPOINT`
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`
- `R2_BUCKET`

Opcionais: `SENTRY_DSN`, `LOKI_*`.

`RAILS_ENV`, `RAILS_SERVE_STATIC_FILES`, `RAILS_LOG_TO_STDOUT` e `ACTIVE_STORAGE_SERVICE` já vão no `compose.prod.yaml`.
