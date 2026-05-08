# ✅ CHECKLIST COMPLETO - Deploy miGarden no Railway

## 📋 Pré-Deploy (Hoje - Local)

### Gerar Secrets
- [ ] Gerar `RAILS_MASTER_KEY`: `rails secret` → copiar para `/tmp/master_key.txt`
- [ ] Gerar `SECRET_KEY_BASE`: `rails secret` → copiar para `/tmp/secret_key.txt`
- [ ] Guardar esses valores com segurança (não commitar!)

### Verificar Arquivos
- [ ] `Procfile` existe e contém:
  ```
  release: sh -c "bundle exec rails db:migrate"
  web: bundle exec rails server -b 0.0.0.0 -p $PORT
  worker: bundle exec sidekiq
  ```
- [ ] `Dockerfile.prod` existe e faz multi-stage build
- [ ] `Gemfile` tem `gem "pg"` para PostgreSQL
- [ ] `.env` não commitado (existe `.env.sample`)
- [ ] `config/database.yml` aceita `DATABASE_URL`

### Teste Local
- [ ] Testar localmente: `docker-compose up --build`
- [ ] Acessar `http://localhost:3000` sem erros
- [ ] Criar uma planta teste
- [ ] Testar API: `curl http://localhost:3000/plants`

### Git
- [ ] Todos os arquivos commitados
- [ ] Nenhuma mudança pending
- [ ] Branch `main` atualizado
- [ ] Fazer push: `git push origin main`

---

## 🚀 Durante Deploy (Railway)

### Conta Railway
- [ ] Criar conta em https://railway.app
- [ ] Login com GitHub
- [ ] Dashboard acessível

### Criar Projeto
- [ ] Clique em **New Project**
- [ ] Selecione **Deploy from GitHub repo**
- [ ] Autorize GitHub
- [ ] Selecione repositório `migarden`
- [ ] Escolha branch `main`
- [ ] Projeto criado

### Adicionar Banco
- [ ] **+ Add Service** → **Database** → **PostgreSQL**
- [ ] Aguardar 2-3 minutos para criar
- [ ] Verificar status: **Connected** ✅

### Configurar Variáveis
- [ ] **Variables** → **+ Add Variable**
- [ ] Adicionar (um a um):

```
RAILS_ENV = production
RAILS_MASTER_KEY = <cola do /tmp/master_key.txt>
SECRET_KEY_BASE = <cola do /tmp/secret_key.txt>
LOG_LEVEL = info
EVOLUTION_API_URL = https://sua-api.com (ou deixar vazio)
EVOLUTION_API_KEY = sua_chave_aqui (ou deixar vazio)
EVOLUTION_INSTANCE = miGarden_prod (ou deixar vazio)
USER_PHONE = 5571992464928 (seu número)
```

- [ ] `DATABASE_URL` pré-preenchida (automática)
- [ ] Verificar todas as variáveis adicionadas

### Deploy
- [ ] Clique em **Deploy** no serviço `app`
- [ ] Aguardar build (~5-10 minutos)
- [ ] Procurar nos logs por: "✅ Migrations completed"
- [ ] Procurar nos logs por: "✅ Puma started"
- [ ] Status final: **Successfully deployed** ✅

---

## ✔️ Pós-Deploy (Validação)

### Testar Web
- [ ] Abrir domínio gerado: `https://seu-dominio.up.railway.app`
- [ ] Página carrega sem erro 500
- [ ] Ver interface (HTML renderizado)
- [ ] Botão para criar planta visível

### Testar API
- [ ] GET /plants: `curl https://seu-dominio.up.railway.app/plants`
- [ ] Retorna JSON (mesmo que vazio)
- [ ] POST /plants funciona:
  ```bash
  curl -X POST https://seu-dominio.up.railway.app/plants \
    -H "Content-Type: application/json" \
    -d '{"plant":{"name":"Rosa","species":"Rosa"}}'
  ```
- [ ] Recebe resposta com `id` e status 201

### Testar Banco
- [ ] Rodar: `railway run bundle exec rails dbconsole`
- [ ] Testar: `SELECT COUNT(*) FROM plants;`
- [ ] Deve retornar número de plantas
- [ ] Sair: `\q`

### Testar Worker
- [ ] Dashboard → **Services** → **worker** → **Logs**
- [ ] Ver mensagem: "Sidekiq started"
- [ ] Nenhum erro [ERROR] visível

### Testar Logs
- [ ] **Services → app → Logs**
- [ ] Ver requisições GET/POST com status 200
- [ ] Nenhum erro [500] visível

---

## 🎛️ Configurações Opcionais (Dashboard)

### Domínio Customizado
- [ ] **Settings → Domains → + Add Domain**
- [ ] Escolher `seu-nome.up.railway.app` ou seu domínio próprio
- [ ] Se próprio, adicionar CNAME no DNS
- [ ] Aguardar propagação (até 24h)

### Auto Deploy
- [ ] **Settings → Auto Deploy**
- [ ] Ativar branch `main`
- [ ] Próximos pushes deployam automaticamente

### Alertas
- [ ] **Settings → Alerts**
- [ ] Ativar Build Failure
- [ ] Ativar Deployment Failure
- [ ] Ativar Service Crashed
- [ ] Email será notificado se algo quebrar

### Monitor
- [ ] Adicionar ao bookmark: `https://railway.app/dashboard`
- [ ] Verificar regularmente:
  - Logs de erro
  - Créditos restantes
  - Status dos serviços

---

## 🔄 Depois do Deploy (Manutenção)

### Primeira Semana
- [ ] Acompanhar logs diários
- [ ] Testar API periodicamente
- [ ] Verificar WhatsApp notifications (se configurado)
- [ ] Documentar problemas encontrados

### Semanal
- [ ] Verificar erros 500 nos logs
- [ ] Confirmar worker rodando
- [ ] Testar criar/editar/deletar planta
- [ ] Confirmar banco crescendo (plantas se acumulando)

### Mensal
- [ ] Revisar créditos Railway usados
- [ ] Otimizar se necessário
- [ ] Fazer backup do banco (opcional)
- [ ] Atualizar dependências

---

## 🐛 Se Algo Quebrar

### Erro: Deploy failed
```
1. Ir em Deployments → Ver logs completos
2. Procurar por [ERROR]
3. Se for "Asset precompilation":
   - Rodar local: bundle exec rails assets:precompile
   - Commit e push
   - Redeploy
```

### Erro: Migrations pending
```
1. Rodar: railway run bundle exec rails db:migrate
2. Verificar se corrigiu
3. Se persistir, restaurar última versão funcional
```

### Erro: Database connection refused
```
1. Verificar se PostgreSQL está "Connected" no dashboard
2. Se não, adicionar PostgreSQL novamente
3. Aguardar 2-3 minutos
4. Redeploy
```

### Erro: Worker not starting
```
1. Verificar Procfile tem: worker: bundle exec sidekiq
2. Verificar variáveis de ambiente completas
3. Redeploy
4. Verificar logs do worker
```

### Erro: Evolution API não conecta
```
1. Verificar se Evolution API está UP
2. Verificar EVOLUTION_API_URL tem "https://"
3. Testar localmente com as mesmas variáveis
4. Se local funciona e railway não, pode ser firewall
```

---

## 📊 Métricas para Acompanhar

### Diário
- ✓ Deploy status (sucesso/falha)
- ✓ Erros 500 nos logs
- ✓ Worker running

### Semanal
- ✓ Requisições bem-sucedidas (status 200)
- ✓ Erros não-tratados
- ✓ Créditos Railway usados

### Mensal
- ✓ Taxa de uptime
- ✓ Performance (resposta lenta?)
- ✓ Crescimento de dados (DB size)

---

## 🎓 Documentação de Referência

Dentro do projeto você agora tem:

| Arquivo | Para |
|---------|------|
| **RAILWAY_QUICK_START.md** | Resumo 5 minutos |
| **RAILWAY_DEPLOYMENT_GUIDE.md** | Guia completo detalhado |
| **RAILWAY_DASHBOARD_VISUAL_GUIDE.md** | Interface do Railway |
| **API_DOCUMENTATION.md** | Como usar a API |
| **LOCAL_TEST_GUIDE.md** | Testar localmente |
| **Procfile** | Processos para Railway |
| **Dockerfile.prod** | Build para produção |

---

## 🚨 Emergency Procedures

### Rollback (voltar versão anterior)
```
1. Railway → Deployments → Histórico
2. Clicar em deploy anterior bem-sucedido
3. Clicar em "Redeploy"
4. Aguardar
```

### Limpar dados (factory reset)
```
1. ⚠️ CUIDADO: Isso deleta TODOS os dados!
2. railway run bundle exec rails db:drop
3. railway run bundle exec rails db:create
4. railway run bundle exec rails db:migrate
```

### Reiniciar serviço
```
1. Dashboard → Services → app/worker
2. Clicar em [...] → Restart
3. Aguardar reiniciar
```

---

## ✨ SUCESSO!

Se passou em todos os checkboxes acima: 🎉

✅ miGarden está **rodando em produção**  
✅ API disponível para uso  
✅ Banco de dados ativo  
✅ Worker processando jobs  
✅ Notificações WhatsApp configuradas (opcional)  

---

**Parabéns! Deploy concluído com sucesso! 🌿🚀**

*Próximo passo: Criar frontend ou conectar uma app mobile à API*
