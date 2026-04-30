# 🌿 miGarden - Ecossistema de Gerenciamento Botânico Inteligente

miGarden é uma plataforma de gerenciamento de plantas que automatiza o ciclo de cuidados botânicos. O sistema calcula datas de rega, fertilização e aplicação de inseticidas, notificando o usuário via WhatsApp através da Evolution API.

## ✨ Funcionalidades
- **Cálculo Inteligente**: Determina a próxima data de cuidado com base no intervalo da espécie.
- **Ajuste Dinâmico**: Aprende com o usuário; se você regar a planta antes do prazo, o sistema sugere ou ajusta a frequência automaticamente.
- **Notificações via WhatsApp**: Alertas diários consolidados com todas as plantas que precisam de atenção.
- **Interface Organic Tech**: Dashboard moderno com efeito de vidro (*glassmorphism*) e design focado em botânica.
- **Gestão Visual**: Suporte a fotos das plantas para identificação rápida.

## 🛠️ Tech Stack
- **Backend**: Ruby on Rails 8 (API & HTML)
- **Banco de Dados**: PostgreSQL 16
- **Background Jobs**: Solid Queue
- **Infraestrutura**: Docker & Docker Compose
- **WhatsApp Gateway**: Evolution API
- **Frontend**: Tailwind CSS + Hotwire (Turbo/Stimulus)

## 🚀 Como Executar (Resumo)
1. Configure as variáveis de ambiente no arquivo `.env`.
2. Suba a infraestrutura: `docker-compose up -d`.
3. Prepare o banco: `docker-compose exec app bundle exec rails db:prepare`.
4. Acesse: `http://localhost:3000`.

---
*Desenvolvido com foco em design orgânico e precisão botânica.*
