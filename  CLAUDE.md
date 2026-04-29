System Instructions: miGarden API

1. Contexto e Objetivo
O miGarden é um ecossistema de gerenciamento botânico inteligente. O sistema controla os ciclos de vida de plantas domésticas, calculando prazos de rega, fertilização e aplicação de inseticidas, notificando o usuário via WhatsApp sobre as tarefas pendentes do dia.

2. Tech Stack & Infraestrutura
Backend: Ruby on Rails 7+ (API Mode).

Database: PostgreSQL (Dev & Prod).

Background Jobs: Solid Queue (preferencial para Rails 8) ou Sidekiq.

Containerização: Docker (Dockerfile multi-stage e docker-compose.yml).

Deployment: Railway (via Dockerfile + Procfile).

WhatsApp Gateway: Evolution API (integração via REST).

3. Arquitetura de Dados (Models)
Plant: name, species, nickname.

CareParameter: * action_type: (enum: :watering, :fertilization, :insecticide).

interval_days: (integer).

CareLog: * performed_at: (date).

action_type: (enum).

observation: (text).

4. Lógica de Notificação e Automação
Cálculo de Próxima Rega: O sistema deve buscar o último CareLog de cada categoria e somar o interval_days do CareParameter.

Notification Engine: * Um Job agendado (Cron) roda diariamente.

Identifica plantas com ações vencendo na data atual.

Formata uma mensagem amigável (ex: "🌿 miGarden Informa: Hoje é dia de regar sua Jiboia e fertilizar o Alecrim!").

Service Pattern: Criar WhatsApp::SendNotificationService para isolar a comunicação com a Evolution API.

5. Diretrizes para o Claude (Instruções de Escrita de Código)
Isolamento de Lógica: Mantenha os Controllers magros. Cálculos de datas e chamadas de API externa devem ficar em app/services.

Configuração de Redes: No docker-compose, garantir que o Rails se comunique com a Evolution API e o Postgres usando os nomes dos serviços como host.

Railway Ready: O Dockerfile deve ser compatível com as variáveis de ambiente do Railway (ex: PORT, DATABASE_URL).

Clean Code: Utilize nomes de métodos semânticos (ex: plant.needs_watering_today?).

6. Comandos de Referência
"Gere o scaffold para as plantas e parâmetros de cuidado do miGarden."

"Implemente o Service Object que formata a mensagem diária do WhatsApp."

"Configure o ambiente Docker para rodar o Rails e a Evolution API simultaneamente."
