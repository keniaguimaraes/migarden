# Guia de Testes Locais - miGarden 🌿

Este guia descreve como subir e testar o ecossistema miGarden utilizando Docker.

## 🚀 Passo a Passo para Subir o Ambiente

### 1. Configuração de Ambiente (Obrigatório)
Antes de subir os containers, você precisa de um arquivo `.env` na raiz do projeto com as seguintes chaves:
```env
POSTGRES_PASSWORD=password
EVOLUTION_API_KEY=sua_chave_da_api
EVOLUTION_INSTANCE=nome_da_instancia
USER_PHONE=5511999999999
```

### 2. Subindo a Infraestrutura
Abra seu terminal e execute:
```bash
docker-compose up -d
```
*Isso subirá o Banco de Dados, a Evolution API e o App Rails em segundo plano.*

### 3. Preparando o Banco de Dados
Com os containers rodando, execute o comando para criar e migrar o banco:
```bash
docker-compose exec app bundle exec rails db:prepare
```

### 4. Acessando a Aplicação
Abra o navegador em: `http://localhost:3000`

---

## 💻 Gerenciamento de Terminais (Como operar)

Você **não precisa abrir vários terminais** para tudo, mas aqui estão as recomendações para cada caso:

### Terminal 1: O Console de Controle (Sempre aberto)
Use este terminal para comandos rápidos de gestão:
- **Reiniciar App:** `docker-compose restart app`
- **Rodar Testes:** `docker-compose exec app bundle exec rspec`
- **Forçar Notificação:** `docker-compose exec app bundle exec rails runner "NotificationEngineService.call"`

### Terminal 2: Monitoramento de Logs (Opcional, mas recomendado)
Se quiser ver o que está acontecendo no servidor em tempo real (erros, requests, logs da Evolution API), abra um segundo terminal e rode:
```bash
docker-compose logs -f app
```
*Deixe este terminal aberto enquanto navega no app para ver os logs de erro instantaneamente.*

### Terminal 3: Console Interativo (Para Debugging)
Sempre que precisar manipular dados manualmente ou testar métodos no console do Rails:
```bash
docker-compose exec app bundle exec rails c
```

---

## 🛠️ Comandos Úteis

| Ação | Comando |
| :--- | :--- |
| **Ver status dos containers** | `docker-compose ps` |
| **Recriar imagem (após mudar Gemfile)** | `docker-compose up -d --build` |
| **Limpar tudo (incluindo banco)** | `docker-compose down -v` |

---

## 🛑 Finalizando
Para desligar todo o ecossistema:
```bash
docker-compose down
```
