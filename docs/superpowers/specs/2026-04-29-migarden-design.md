# Design do miGarden - Ecossistema de Gerenciamento Botânico Inteligente

## 1. Visão Geral
O miGarden é um sistema projetado para ajudar usuários a manterem suas plantas saudáveis, calculando automaticamente as datas de rega, fertilização e aplicação de inseticidas, e notificando o usuário via WhatsApp.

## 2. Arquitetura de Dados

### Modelos
- **Plant (Planta)**: Entidade principal.
    - `name`: Nome da planta.
    - `species`: Espécie botânica.
    - `nickname`: Nome carinhoso dado pelo usuário.
- **CareParameter (Parâmetro de Cuidado)**: Define a frequência de cada ação.
    - `plant_id`: Referência à planta.
    - `action_type`: Enum (`:watering`, `:fertilization`, `:insecticide`).
    - `interval_days`: Intervalo em dias entre as ações (ex: 7 para semanal).
- **CareLog (Log de Cuidado)**: Registro de quando uma ação foi realizada.
    - `plant_id`: Referência à planta.
    - `care_parameter_id`: Referência ao parâmetro de cuidado.
    - `performed_at`: Data da execução.
    - `observation`: Notas adicionais sobre a ação.

## 3. Lógica de Notificação e Automação

### Cálculo de Necessidade (`CareCalculatorService`)
O sistema identifica se uma planta precisa de cuidado hoje seguindo a regra:
- Busca o último `CareLog` para o `CareParameter` específico.
- Se não houver log, a planta é considerada "pendente".
- Se houver log, calcula: `performed_at + interval_days`.
- Se a data resultante for $\le$ hoje, a ação está vencida ou é para hoje.

### Engine de Notificação (`NotificationEngineService`)
1. Identifica todas as plantas e ações pendentes para a data atual.
2. Agrupa as ações por tipo (ex: Rega: [Planta A, Planta B]).
3. Formata uma mensagem única e amigável em português.

### Integração WhatsApp (`WhatsApp::SendNotificationService`)
- **Gateway**: Evolution API.
- **Método**: Requisição POST para o endpoint de envio de texto.
- **Configuração**: Chaves de API e nomes de instâncias via variáveis de ambiente.

## 4. Infraestrutura e Deployment

### Tech Stack
- **Backend**: Ruby on Rails 7+ (API Mode).
- **Banco de Dados**: PostgreSQL.
- **Filas/Jobs**: Solid Queue (Padrão Rails 8).
- **Container**: Docker (Dockerfile multi-stage + docker-compose).
- **Hospedagem**: Railway.

### Estratégia de Deployment
- **Docker Compose**: Orquestra Rails, Postgres e a imagem da Evolution API.
- **Railway**: Deploy via Dockerfile com `Procfile` para gerenciar o servidor web e o worker do Solid Queue.
- **Agendamento**: Job diário (`DailyNotificationJob`) disparado via cron/scheduler para processar as notificações.

## 5. Fluxo de Trabalho (Dev)
- **Controllers**: Devem ser magros, delegando lógica para `app/services`.
- **Clean Code**: Métodos semânticos (ex: `plant.needs_watering_today?`).
- **Isolamento**: Lógica de API externa estritamente isolada em Services.
