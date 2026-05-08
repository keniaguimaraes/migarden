# ⚡ QUICK START - Railway Deploy (5 Minutos)

## 🎯 ANTES DO DEPLOY (Local)

### 1. Gerar Keys
```bash
cd /Users/keniaguimaraes/Projects/migarden
rails secret > /tmp/master_key.txt  # Salve este valor!
rails secret > /tmp/secret_key.txt  # E este também!
cat /tmp/master_key.txt
```

### 2. Fazer Commit
```bash
git add .
git commit -m "Prepare Railway deployment"
git push origin main
```

---

## 🚀 NO RAILWAY (10 minutos)

### 1. Criar Projeto
- Acesse: https://railway.app
- **New Project** → **Deploy from GitHub**
- Selecione `migarden` repository

### 2. Adicionar PostgreSQL
- **+ Add Service**
- Escolha **Database → PostgreSQL**
- Pronto! Railway cria automaticamente

### 3. Configurar Variáveis (COPIE EXATAMENTE)

```
RAILS_ENV=production
RAILS_MASTER_KEY=<cole o valor de /tmp/master_key.txt aqui>
SECRET_KEY_BASE=<cole o valor de /tmp/secret_key.txt aqui>
EVOLUTION_API_URL=https://sua-evolution-api.com
EVOLUTION_API_KEY=sua_chave_aqui
EVOLUTION_INSTANCE=miGarden_prod
USER_PHONE=5571992464928
LOG_LEVEL=info

# DATABASE_URL será preenchida automaticamente pelo Railway
```

**Como adicionar:**
1. Dashboard → Seu projeto → **Variables**
2. **+ Add Variable**
3. Nome: `RAILS_ENV`, Valor: `production`
4. Repita para cada uma acima

### 4. Deploy
- Clique em **Deploy** no projeto
- Railway fará tudo automaticamente
- Aguarde ~5-10 minutos

### 5. Verificar Deployment
```
Dashboard → Deployments → Ver logs completos
Procure por: "Migrations completed" ✅
```

---

## ✅ DEPOIS DO DEPLOY

### Testar Web
```
Abra: https://seu-dominio.up.railway.app/plants
Deve mostrar lista de plantas (pode estar vazia)
```

### Testar DB (se precisar)
```bash
# Conectar ao banco railway
railway run bundle exec rails dbconsole

# Dentro do terminal:
\dt  # Listar tabelas
SELECT COUNT(*) FROM plants;  # Ver plantas
\q   # Sair
```

### Testar API (POST)
```bash
curl -X POST https://seu-dominio.up.railway.app/plants \
  -H "Content-Type: application/json" \
  -d '{
    "plant": {
      "name": "Rosa",
      "species": "Rosa vermelha",
      "location": "Sala",
      "watering_interval": 3
    }
  }'
```

---

## 🎯 CONFIGURAR NO DASHBOARD RAILWAY

### Domínio Customizado (Opcional)
1. **Settings → Domains**
2. **+ Add Domain**
3. Escolha `seu-nome.up.railway.app`
4. Railway fornecerá um CNAME se quiser seu domínio próprio

### Auto Deploy (Recomendado)
1. **Settings → Auto Deploy**
2. Ativar branch `main`
3. Próximos pushes deployam automaticamente

### Monitor Aplicação
1. **Seu Projeto → Logs** (acompanhe erros em tempo real)
2. **Services → app → Logs** (ver requisições)
3. **Services → worker → Logs** (ver jobs background)

---

## 🆘 PROBLEMAS COMUNS

| Problema | Solução |
|----------|---------|
| "No database found" | Aguardar 2 min após criar PostgreSQL, depois redeploy |
| "Migrations not running" | `railway run bundle exec rails db:migrate` |
| "Erro 500" | Ver **Logs** → procurar por `Error` |
| "Worker não inicia" | Verificar Procfile tem `worker: bundle exec sidekiq` |
| "Evolution API não conecta" | Verificar EVOLUTION_API_URL com https:// |

---

## 📝 API ROUTES DISPONÍVEIS

```bash
# Listar plantas
GET /plants

# Criar planta
POST /plants
{
  "plant": {
    "name": "Rosa",
    "species": "Rosa vermelha",
    "location": "Sala",
    "watering_interval": 3
  }
}

# Atualizar planta
PATCH /plants/:id
{ "plant": { "name": "Nova Rosa" } }

# Deletar planta
DELETE /plants/:id

# Registrar cuidado (rega, fertilização, etc)
POST /care_logs
{
  "care_log": {
    "plant_id": 1,
    "care_type": "watering",
    "performed_at": "2026-05-08T10:30:00"
  }
}

# Parâmetros de cuidado
GET /plants/:id/care_parameters
POST /plants/:id/care_parameters
```

---

## 🎓 Arquivos Importantes

- [RAILWAY_DEPLOYMENT_GUIDE.md](RAILWAY_DEPLOYMENT_GUIDE.md) - Guia completo (detalhado)
- [Procfile](Procfile) - Define processos web e worker
- [Dockerfile.prod](Dockerfile.prod) - Build da imagem production
- [config/routes.rb](config/routes.rb) - Rotas disponíveis

---

**Status do seu projeto: ✅ Pronto para deploy!**
