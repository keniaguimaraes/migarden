# 🚀 Guia Completo: Deploy no Railway - miGarden

## PARTE 1: ANTES DO DEPLOY (Preparação Local)

### 1️⃣ Verificar Configuração do Projeto

```bash
# 1. Gerar Rails Master Key (se não tiver)
cd /Users/keniaguimaraes/Projects/migarden
rails secret
# Copie a saída (será usada depois no Railway)
```

### 2️⃣ Verificar Arquivos Essenciais

✅ **Procfile** - Deve ter:
```
release: sh -c "bundle exec rails db:migrate"
web: bundle exec rails server -b 0.0.0.0 -p $PORT
worker: bundle exec sidekiq
```

✅ **Dockerfile.prod** - Multi-stage (já tem)

✅ **config/database.yml** - Deve aceitar `DATABASE_URL`

✅ **Gemfile** - Deve ter postgres gem:
```ruby
gem "pg", "~> 1.5"  # Para produção
```

### 3️⃣ Commit e Push no GitHub

```bash
git add .
git commit -m "Prepare for Railway deployment"
git push origin main
```

---

## PARTE 2: CRIAR PROJETO NO RAILWAY

### ✅ Passo 1: Criar Conta no Railway
- Acesse: https://railway.app
- Cadastre com GitHub
- Crie um novo projeto

### ✅ Passo 2: Conectar Repositório GitHub
1. No dashboard Railway → **New Project**
2. Escolha **Deploy from GitHub repo**
3. Autorize e selecione `migarden`
4. Escolha branch `main`

### ✅ Passo 3: Criar Serviços

**A. PostgreSQL (Banco de Dados)**
1. No projeto Railway → **+ Add Service**
2. Escolha **Database → PostgreSQL**
3. Use a versão padrão (16+)
4. Conecte ao projeto principal

**B. Configuração Web (Rails)**
1. Railway detectará automaticamente como Rails
2. Ou → **+ Add Service → GitHub Repo**
3. Selecione seu repositório

---

## PARTE 3: CONFIGURAR VARIÁVEIS DE AMBIENTE

### 📋 Variáveis Necessárias

No dashboard Railway, abra seu projeto e vá em **Variables**:

| Variável | Valor | Obtenção |
|----------|-------|----------|
| `RAILS_ENV` | `production` | Padrão |
| `RAILS_MASTER_KEY` | `sua_master_key` | `rails secret` (gerada no passo 1) |
| `SECRET_KEY_BASE` | `rails secret` | Gere outro com `rails secret` |
| `POSTGRES_PASSWORD` | Auto (Railway) | Railway preenche ao criar DB |
| `DATABASE_URL` | Auto (Railway) | Railway preenche automaticamente |
| `EVOLUTION_API_URL` | `https://sua-evolution-api.com` | Seu servidor Evolution |
| `EVOLUTION_API_KEY` | `sua_chave_api` | Dashboard Evolution API |
| `EVOLUTION_INSTANCE` | `miGarden_prod` | Nome da instância |
| `USER_PHONE` | `5571992464928` | Seu número com DDI |
| `LOG_LEVEL` | `info` | Para production |

### 🔧 Como adicionar no Railway

```
1. Dashboard → Seu Projeto → Variables
2. + Add Variable
3. Nome: RAILS_MASTER_KEY
4. Valor: (cole a chave gerada)
5. Clique em ✓ Save
6. Repita para todas as variáveis
```

---

## PARTE 4: DEPLOY

### ✅ Deploy Manual

1. Após configurar variáveis → **Deploy**
2. Railway fará automaticamente:
   - Build com `Dockerfile.prod`
   - Push da imagem
   - Inicia o container
   - Executa migrations (via `Procfile` release phase)

### ✅ Logs de Deploy

Para acompanhar:
```
Dashboard → Seu Projeto → Deployments → Ver Logs Completos
```

Procure por:
```
✅ "Migrations completed"
✅ "Puma started"
✅ Worker iniciado
```

---

## PARTE 5: PÓS-DEPLOY - Configuração do Banco

### ✅ Executar Migrations (se não rodou automático)

```bash
# Via Railway CLI
railway run bundle exec rails db:migrate

# Ou via dashboard → Terminal → Input:
bundle exec rails db:migrate
```

### ✅ Popular Banco (Seeds - opcional)

Se tiver `db/seeds.rb`:
```bash
railway run bundle exec rails db:seed
```

### ✅ Verificar Banco Criado

```bash
# Conectar ao PostgreSQL Railway
railway run bundle exec rails dbconsole

# Dentro do psql:
\dt  # Listar tabelas
SELECT * FROM plants LIMIT 1;  # Testar conexão
\q   # Sair
```

---

## PARTE 6: VERIFICAR SE ESTÁ RODANDO

### ✅ Testar Web Server

```
Seu domínio Railway:
https://seu-dominio.up.railway.app

Deve mostrar:
- Página inicial (ou redirect)
- Sem erro 500
```

### ✅ Testar API Routes

Abra no navegador:
```
https://seu-dominio.up.railway.app/plants
```

Deve retornar:
```json
[
  {
    "id": 1,
    "name": "Rosa",
    ...
  }
]
```

### ✅ Verificar Worker (Sidekiq)

No dashboard Railway:
```
1. Abra o serviço "worker"
2. Vá em Logs
3. Procure por "Sidekiq started"
```

---

## PARTE 7: API ROUTES DISPONÍVEIS

Seu Rails está configurado com essas rotas:

```ruby
# Listar todas as plantas
GET /plants

# Criar planta
POST /plants
Body: {
  "plant": {
    "name": "Rosa Vermelha",
    "species": "Rosa",
    "location": "Sala",
    "watering_interval": 3
  }
}

# Atualizar planta
PATCH /plants/:id
Body: { "plant": { "name": "Novo Nome" } }

# Deletar planta
DELETE /plants/:id

# Parâmetros de cuidado
GET /plants/:id/care_parameters
POST /plants/:id/care_parameters
DELETE /plants/:id/care_parameters/:id

# Registrar cuidado realizado
POST /care_logs
Body: {
  "care_log": {
    "plant_id": 1,
    "care_type": "watering",
    "performed_at": "2026-05-08T10:30:00"
  }
}
```

---

## PARTE 8: CONFIGURAÇÕES NO DASHBOARD RAILWAY

### 🔧 Domínio Customizado

1. **Seu Projeto → Settings → Domains**
2. **+ Add Domain**
3. Escolha: `seu-dominio.up.railway.app` ou seu próprio
4. CNAME se usar domínio próprio

### 🔧 Ambiente de Staging

Para testar antes de produção:
1. **New Environment → staging**
2. Duplicate variables do `production`
3. Use branch `develop` (se tiver)
4. Deploy separado

### 🔧 Auto Deploy

1. **Seu Projeto → Settings → Auto Deploy**
2. Ativar para branch `main`
3. Próximos pushes deployam automaticamente

### 🔧 Alertas e Monitoramento

1. **Settings → Alerts**
2. Receber notificação se:
   - Build falhar
   - Créditos acabarem
   - Aplicação cair

---

## PARTE 9: SOLUÇÃO DE PROBLEMAS

### ❌ Erro: "No database found"
```
Solução:
1. Verificar se PostgreSQL está conectado
2. Ir em Services e adicionar o plugin PostgreSQL
3. Aguardar 2-3 minutos para Railway criá-lo
4. Redeploy
```

### ❌ Erro: "Migration pending"
```
Solução:
railway run bundle exec rails db:migrate
```

### ❌ Erro: "Asset precompilation failed"
```
Solução:
1. Verificar Dockerfile.prod
2. Garantir que tailwindcss está no Gemfile
3. Rodar localmente: bundle exec rails assets:precompile
4. Commit e push
5. Redeploy
```

### ❌ Worker não inicia
```
Solução:
1. Verificar Procfile:
   worker: bundle exec sidekiq
2. Se for Solid Queue (novo Rails):
   worker: bundle exec rails solid_queue:start
```

### ❌ Evolution API não conecta
```
Solução:
1. Verificar variáveis:
   - EVOLUTION_API_URL (com https://)
   - EVOLUTION_API_KEY
   - EVOLUTION_INSTANCE
2. Testar localmente com .env
3. Verificar se Evolution API está UP
```

---

## PARTE 10: CHECKLIST FINAL

- [ ] Master key gerada e guardada com segurança
- [ ] Variáveis de ambiente configuradas no Railway
- [ ] PostgreSQL criado e conectado
- [ ] Deploy executado com sucesso
- [ ] Migrations rodaram (verificar logs)
- [ ] Web server respondendo (testar URL)
- [ ] API routes funcionando (GET /plants)
- [ ] Worker iniciado (verificar logs Sidekiq)
- [ ] Evolution API conectada (se usar WhatsApp)
- [ ] Domínio configurado (opcional)

---

## 📞 Suporte

Se der erro, verifique nesta ordem:
1. **Logs do Deployment** - Railway Dashboard → Deployments
2. **Application Logs** - Seu serviço → Logs
3. **Database Connection** - Testar com `dbconsole`
4. **Environment Variables** - Verificar se todas estão presentes
5. **Procfile** - Validar sintaxe

---

**Desenvolvido para miGarden - Ecossistema de Gerenciamento Botânico**
