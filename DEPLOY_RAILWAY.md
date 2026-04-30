# Deploy no Railway - miGarden

## Pré-requisitos
- Conta no [Railway](https://railway.app)
- Repositório GitHub conectado à Railway

## Passo a Passo

### 1. Conectar o Repositório
1. Acesse o dashboard da Railway.
2. Clique em **New Project**.
3. Escolha **Deploy from GitHub repo**.
4. Selecione o repositório `migarden`.

### 2. Configurar Variáveis de Ambiente
No painel do Railway, vá em **Variables** e adicione:

| Variável | Valor |
| :--- | :--- |
| `POSTGRES_PASSWORD` | senha_do_banco |
| `DATABASE_URL` | (Railway preenche automaticamente se você adicionar o plugin PostgreSQL) |
| `RAILS_MASTER_KEY` | gerar com `rails secret` |
| `EVOLUTION_API_KEY` | sua_chave_da_api |
| `EVOLUTION_INSTANCE` | nome_da_instancia |
| `EVOLUTION_API_URL` | URL da Evolution API (se usar serviço externo) |
| `USER_PHONE` | seu_numero_com_ddi |

### 3. Configurar o Banco de Dados
1. No painel do Railway, clique em **New** → **Database** → **PostgreSQL**.
2. Após criado, a variável `DATABASE_URL` será preenchida automaticamente.

### 4. Fazer o Deploy
1. Após configurar as variáveis, clique em **Deploy**.
2. O Railway usará o `Dockerfile.prod` automaticamente.
3. Aguarde o build terminar (pode levar alguns minutos).

### 5. Verificar
1. Após o deploy, clique no domínio gerado (ex: `https://migarden.up.railway.app`).
2. Acesse `/plants` para verificar se a interface carrega.

---

## Observações
- O `Procfile` já está configurado com `web` e `worker` para o Solid Queue.
- O `Dockerfile.prod` faz build multi-stage para imagem menor.
- O Rails usará `RAILS_ENV=production` automaticamente no Railway.