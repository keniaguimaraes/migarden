# 🔧 Como as Migrations Funcionam Agora

## Fluxo de Execução no Railway

```
1. Railway inicia container
   ↓
2. Dockerfile executa ENTRYPOINT: /app/docker-entrypoint.sh
   ↓
3. docker-entrypoint.sh:
   - Limpa PID files
   - Aguarda database
   - Testa conexão
   - Roda db:prepare
   - Roda migrations com VERBOSE
   - Mostra status final
   ↓
4. docker-entrypoint.sh executa comando do Procfile
   ↓
5. Procfile release: executa migrations de novo (redundante mas seguro)
   ↓
6. Procfile web: inicia Puma (web server)
   ↓
7. Procfile worker: inicia Sidekiq (background jobs)
```

---

## ✅ O Que Vai Acontecer no Deploy

### Deploy Logs Esperados

```
[build] Building image...
[push] Pushing image to registry...
[deploy] Starting container...

========================================
=== Docker Entrypoint Starting ===
========================================
Container started at: Thu May 8 20:00:00 UTC 2026
User: rails
Working directory: /app

[1/6] Cleaning up stale PID files...
✓ PID files cleaned

[2/6] Waiting for database to be ready...
✓ Database ready (waited 10 seconds)

[3/6] Testing database connection...
✓ Database connection OK

[4/6] Running database setup (db:prepare)...
✓ Database setup completed

[5/6] Running migrations (verbose)...
== 20260429212304 CreatePlants: migrating ========================
-- create_table(:plants)
   -> 0.0234s
== 20260429212304 CreatePlants: migrated (0.0234s) =================

== 20260429212305 CreateCareParameters: migrating ================
-- create_table(:care_parameters)
   -> 0.0142s
== 20260429212305 CreateCareParameters: migrated (0.0142s) =======

[6/6] Checking migration status...
 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20260429212304  CreatePlants
   up     20260429212305  CreateCareParameters
   up     20260429212306  CreateCareLogs
   up     20260429212628  AddNullConstraintsToCare...
   up     20260429212954  CreateActiveStorageTables

==========================================
=== Application Ready ===
Startup completed at: Thu May 8 20:00:15 UTC 2026
==========================================

Starting command: bundle exec rails server -b 0.0.0.0
[20:00:16] Puma server started on port 3000
[20:00:17] Sidekiq started
```

---

## 📋 Procfile Explicado

```procfile
# Rodado ANTES de iniciar web/worker
release: bundle exec rails db:migrate --verbose && echo "=== MIGRATIONS COMPLETED ===" && bundle exec rails db:migrate:status

# Web server (Puma)
web: bundle exec rails server -b 0.0.0.0 -p $PORT

# Background jobs (Sidekiq)
worker: bundle exec sidekiq
```

**Como Railway interpreta:**
1. **release**: Executa uma única vez antes de iniciar outros processos
2. **web**: Inicia o servidor web (pode ter múltiplas instâncias)
3. **worker**: Inicia o worker (background jobs)

---

## 🚀 Próximo Deploy

### Passos
```bash
# 1. Commit das mudanças
git add Dockerfile.prod Procfile docker-entrypoint.sh
git commit -m "Fix: Add ENTRYPOINT to Dockerfile and improve Procfile"
git push origin main

# 2. Railway detecta push
# 3. Railway builds a imagem
# 4. Railway inicia container
# 5. ENTRYPOINT executa (migrations rodam com verbose logs)
# 6. Web server inicia
# 7. Worker inicia
```

### Ver Logs
```
Dashboard → Deployments → Deploy recente → Ver Logs
```

---

## 🔍 Debugar se Migrations Não Rodarem

### Via Railway Dashboard
```
1. Seu projeto → Terminal
2. Rodar: bundle exec rails db:migrate:status
3. Rodar: bundle exec rails db:migrate --verbose
```

### Via Railway CLI
```bash
railway run bundle exec rails db:migrate:status
railway run bundle exec rails db:migrate --verbose
railway run cat /tmp/migration.log  # Ver log salvo
```

### Ver Logs do Container
```
Dashboard → Services → app → Logs
Procure por:
- "Entrypoint Starting"
- "Running migrations"
- "Migrations completed"
```

---

## 🎯 Importante

### ⚠️ Migrations Rodam em 2 Lugares

1. **docker-entrypoint.sh**: Roda SEMPRE quando container inicia
2. **Procfile release**: Roda apenas na primeira vez (pode ser redundante)

**Por que 2 lugares?**
- docker-entrypoint.sh: Garante que rodem sempre que container sobe
- Procfile release: Standard do Railway, fornece output estruturado

**Isso é um problema?**
- ❌ Não! Rails é smart e skippa migrations já rodadas
- ✅ Se migration já foi, não roda de novo
- ✅ Se for nova, roda só uma vez

---

## 📊 Checklist Antes de Deployar

- [ ] Dockerfile.prod tem ENTRYPOINT e CMD?
- [ ] docker-entrypoint.sh é executável e readable?
- [ ] Procfile tem release, web, worker?
- [ ] Commits feitos: `git push origin main`?
- [ ] Esperando build no Railway?

---

## ✅ Status da Sua Aplicação

| Componente | Status | Verificação |
|------------|--------|-------------|
| Dockerfile.prod | ✅ Fixo | ENTRYPOINT adicionado |
| docker-entrypoint.sh | ✅ Melhorado | Logs detalhados |
| Procfile | ✅ Simplificado | release/web/worker claro |
| Migrations | ✅ Automático | Rodam com verbose logs |
| Database | ✅ PostgreSQL | Conectado no Railway |

---

**Seu deployment agora será muito mais transparente! 🎉**

Você verá exatamente o que está acontecendo com as migrations em tempo real.
