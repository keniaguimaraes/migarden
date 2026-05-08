# 🔍 Debug Migrations - miGarden no Railway

## Problema: Migrations não estão criando tabelas

Se você está vendo que o banco está vazio mesmo após deploy, use este guia.

---

## 🚀 Passo 1: Ver Logs do Deploy

**No Railway Dashboard:**
1. Seu projeto → **Deployments**
2. Clique no deploy mais recente
3. Abra **"Ver Logs Completos"**
4. Procure por:
   - `[ERROR]` ou `Error` - há algum erro?
   - `[FATAL]` - erro fatal?
   - `migration` - foi rodada?
   - `Migrations completed` - completou?

---

## 🔧 Passo 2: Rodar Debug Localmente

### 2.1 Com Docker (Recomendado)

```bash
cd /Users/keniaguimaraes/Projects/migarden

# Derrubar containers
docker-compose down

# Subir do zero
docker-compose up --build

# Em outro terminal, rodar debug
docker-compose exec app bash /app/debug_migrations.sh
```

### 2.2 Sem Docker (Local)

```bash
# Testar conexão com DB
rails dbconsole

# Ver status das migrations
rails db:migrate:status

# Rodar migrations com verbose
rails db:migrate --verbose

# Verificar tabelas criadas
rails dbconsole
> SELECT * FROM information_schema.tables WHERE table_schema = 'public';
```

---

## 🔧 Passo 3: Rodar Debug no Railway

### Via Railway CLI

```bash
# Instalar Railway CLI
npm i -g @railway/cli

# Login
railway login

# Conectar ao projeto
railway link

# Rodar script de debug
railway run bash /app/debug_migrations.sh

# Ou rodar migrations manualmente
railway run bundle exec rails db:migrate:status
railway run bundle exec rails db:migrate --verbose
```

### Via Dashboard Terminal

1. Dashboard → Seu projeto → **Terminal**
2. Colar comando:
```bash
bundle exec rails db:migrate:status
```
3. Pressionar Enter

---

## 🐛 Problemas Comuns & Soluções

### Erro 1: "PG::ConnectionBad"
```
PG::ConnectionBad: could not connect to server
```

**Solução:**
- Verificar se PostgreSQL está conectado no Railway
- Verificar variável `DATABASE_URL`
- Aguardar 2-3 min se PostgreSQL foi criado recentemente

### Erro 2: "Relation already exists"
```
PG::DuplicateTable: ERROR: relation "plants" already exists
```

**Solução:**
- Tabelas já existem, continuar normalmente
- Para limpar (⚠️ PERDERIA DADOS):
```bash
railway run bundle exec rails db:drop
railway run bundle exec rails db:create
railway run bundle exec rails db:migrate
```

### Erro 3: "No such file or directory"
```
No such file or directory @ rb_sysopen
```

**Solução:**
- Migrations não estão sendo copiadas para o container
- Verificar se migrations estão em `db/migrate/`
- Fazer rebuild do Docker: `docker-compose up --build`

### Erro 4: "Version not found"
```
Couldn't find migration version 20260429212304
```

**Solução:**
- Verificar se o arquivo de migration existe
- Verificar o nome do arquivo (sem typos)
- Regenerar com: `rails db:migrate:status`

---

## 📊 O Que Procurar nos Logs

### ✅ Sucesso
```
== 20260429212304 CreatePlants: migrating ========================
-- create_table(:plants)
   -> 0.0234s
== 20260429212304 CreatePlants: migrated (0.0234s) ===============

== 20260429212305 CreateCareParameters: migrating ===============
-- create_table(:care_parameters)
   -> 0.0142s
== 20260429212305 CreateCareParameters: migrated (0.0142s) =======

[SUCCESS] Migrations completed
```

### ❌ Erro
```
== 20260429212304 CreatePlants: migrating ========================
-- create_table(:plants)
   -> ERROR: unrecognized configuration parameter "idle_in_transaction_session_timeout"
   -> 0.0000s
Caused by /app/db/migrate/20260429212304_create_plants.rb:1
```

---

## 🔍 Verificações Passo a Passo

### 1. Database Connection
```bash
railway run bundle exec rails dbconsole <<< "SELECT 1;"
# Esperado: resposta sem erro
```

### 2. Migration Files
```bash
railway run ls -la db/migrate/
# Esperado: listar 5 arquivos .rb
```

### 3. Current Status
```bash
railway run bundle exec rails db:migrate:status
# Esperado: listar todas migrations com status
```

### 4. Run Migrations
```bash
railway run bundle exec rails db:migrate --verbose
# Esperado: "migrated" para cada uma
```

### 5. Verify Tables
```bash
railway run bundle exec rails dbconsole <<< "
  SELECT table_name FROM information_schema.tables 
  WHERE table_schema = 'public';
"
# Esperado: plants, care_parameters, care_logs, active_storage_*
```

### 6. Check Data
```bash
railway run bundle exec rails console <<< "
  puts 'Plants: ' + Plant.count.to_s
  puts 'Care Parameters: ' + CareParameter.count.to_s
  puts 'Care Logs: ' + CareLog.count.to_s
"
# Esperado: 3 linhas com contagem (pode ser 0 se vazio)
```

---

## 📝 Passos para Corrigir

### Se nenhuma tabela foi criada:

```bash
# 1. Ver status
railway run bundle exec rails db:migrate:status

# 2. Se estiver "down", rodar:
railway run bundle exec rails db:migrate

# 3. Verificar depois:
railway run bundle exec rails db:migrate:status

# 4. Se der erro, ver logs:
railway run bundle exec rails db:migrate --verbose 2>&1 | tee /tmp/migration.log
```

### Se algumas tabelas foram criadas (parcial):

```bash
# Não remova o banco, apenas rode de novo:
railway run bundle exec rails db:migrate --verbose

# Se der "already exists", está normal - continuar
# Rails skippa migrations já rodadas
```

### Se não conseguir migrar:

```bash
# ⚠️ ÚLTIMA SOLUÇÃO (PERDERIA DADOS!)
railway run bundle exec rails db:drop
railway run bundle exec rails db:create
railway run bundle exec rails db:migrate --verbose
```

---

## 📞 Se Ainda Não Funcionar

1. **Fazer backup de qualquer dado importante** 
2. Verificar arquivo [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md#-se-algo-quebrar)
3. Tentar rollback: Railway Deployments → deploy anterior → Redeploy
4. Conferir [FIX_SOLID_QUEUE_ERROR.md](FIX_SOLID_QUEUE_ERROR.md)

---

## 🎯 Resumo Rápido

| Situação | Comando |
|----------|---------|
| Ver se migrations rodaram | `railway run rails db:migrate:status` |
| Rodar debug completo | `railway run bash debug_migrations.sh` |
| Conectar ao DB | `railway run rails dbconsole` |
| Rodar migrations | `railway run rails db:migrate --verbose` |
| Ver últimas migrations | `railway run rails db:migrate:status ∣ tail -5` |

---

**Logs foram adicionados ao Procfile e docker-entrypoint.sh!** 🎉

Próxima vez que deployar, verá muito mais informação.
