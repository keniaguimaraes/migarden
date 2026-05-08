# 🔧 FIX - Corrigir Erro "solid_queue:start"

## ❌ Problema Identificado

Você estava recebendo:
```
Don't know how to build task 'solid_queue:start'
```

## ✅ Causa & Solução

### Problema
1. O `Gemfile` tinha `gem "sqlite3"` (para desenvolvimento)
2. Mas em **produção** precisa usar PostgreSQL (`pg`)
3. Isso causava conflitos com o worker (Sidekiq)

### Solução Implementada
✅ Removido `gem "sqlite3"` do Gemfile  
✅ Mantido `gem "pg"` para produção  
✅ Procfile já estava correto com `bundle exec sidekiq`  

---

## 🚀 Como Fazer Deploy Agora (Passo a Passo)

### 1️⃣ Limpar Localmente

```bash
cd /Users/keniaguimaraes/Projects/migarden

# Remover lockfile antigo
rm Gemfile.lock

# Remover vendor
rm -rf vendor

# Remover bundle cache
rm -rf .bundle
```

### 2️⃣ Regenerar Gemfile.lock

```bash
# Instalar dependências novamente
bundle install

# Ou se estiver usando Docker:
docker-compose down
docker-compose up --build
```

### 3️⃣ Testar Localmente

```bash
# Com Docker
docker-compose up

# Sem Docker
rails db:prepare
rails server -b 0.0.0.0 -p 3000

# Em outro terminal
redis-server  # Se estiver rodando localmente

# Em terceiro terminal (worker)
bundle exec sidekiq
```

### 4️⃣ Commit & Push

```bash
git add Gemfile Gemfile.lock
git commit -m "Fix: Remove sqlite3, use pg for production"
git push origin main
```

### 5️⃣ Deploy no Railway

**Dashboard Railway:**
1. Ir em **Deployments**
2. Clicar em **Deploy** (irá usar novo código)
3. Aguardar build (~5 min)
4. Verificar logs por:
   - ✅ "Migrations completed"
   - ✅ "Puma started"
   - ✅ "Sidekiq started" (no worker)

---

## ✔️ Verificação Pós-Deploy

### Testar Web Server
```bash
curl https://seu-dominio.up.railway.app/plants
# Deve retornar JSON (mesmo que vazio)
```

### Testar Worker
```
Dashboard → Services → worker → Logs
Procure por: "Sidekiq started"
```

### Testar Database
```bash
railway run bundle exec rails dbconsole
SELECT COUNT(*) FROM plants;
\q
```

---

## 📋 Checklist Rápido

- [ ] Deletado `Gemfile.lock`
- [ ] Rodado `bundle install`
- [ ] Testado localmente (web server rodando)
- [ ] Testado Sidekiq localmente (sem erros)
- [ ] Commitado e fez push
- [ ] Fez deploy no Railway
- [ ] Verificou migrations nos logs
- [ ] API respondendo no domínio
- [ ] Worker iniciando sem erros

---

## 🎯 Se Ainda Tiver Erro

### Opção 1: Forçar rebuild no Railway
```
1. Dashboard → Services → app
2. Clicar em [...] → Redeploy
3. Aguardar
```

### Opção 2: Verificar Procfile
```bash
cat Procfile
```
Deve ter:
```
release: sh -c "echo '=== Running migrations ===' && bundle exec rails db:migrate && echo '=== Migrations done ==='"
web: bundle exec rails server -b 0.0.0.0 -p $PORT
worker: bundle exec sidekiq
```

### Opção 3: Ver logs detalhados
```
Dashboard → Deployments → Deploy mais recente → Ver Logs Completos
Procure por [ERROR]
```

---

## 📝 Resumo das Mudanças

| Arquivo | O Quê | Resultado |
|---------|-------|-----------|
| Gemfile | Remover sqlite3, manter pg | ✅ Banco pronto para produção |
| Procfile | Já estava correto | ✅ Sidekiq configurado |
| Dockerfile.prod | Já estava correto | ✅ Build multi-stage ok |

---

**Seu projeto agora está pronto para Railway! 🌿🚀**
