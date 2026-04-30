# Análise do Fluxo do Sistema: Aplicação MiGarden

Este documento detalha os fluxos operacionais centrais da aplicação MiGarden, cobrindo o processamento de requisições, operações CRUD para plantas, o sistema de gerenciamento de cuidados, e os pipelines de notificação, além da configuração do ambiente.

---

## 1. Ciclo de Vida da Requisição

A aplicação parece seguir uma arquitetura **Ruby on Rails** padrão, profundamente integrada com práticas modernas de front-end usando **Hotwire (Turbo/Stimulus)** para atualizações dinâmicas.

### Fluxo de Alto Nível:

1.  **Interação do Navegador:** O usuário interage com a página (ex: clicando em um link ou submetendo um formulário).
    *   **Turbo Frames/Streams:** Se a interação for dentro de um contexto Turbo, a requisição é enviada, e o servidor responde com fragmentos de HTML ou atualizações de Turbo Stream, que os controladores Stimulus ou ouvintes Turbo processam para atualizar o DOM **sem recarregar a página inteira**.
    *   **Carregamento Completo de Página:** Links padrão resultam em uma requisição de página HTML completa.
2.  **Roteador Rails (`config/routes.rb`):** A requisição é mapeada para uma ação de controlador específica (`<Controller>#<Action>`).
3.  **Controlador (`*Controller`):**
    *   Executa verificações de autorização.
    *   Busca dados necessários no banco de dados via Models (ex: `Plant.find(params[:id])`).
    *   Processa os parâmetros da requisição (`params`).
    *   Prepara variáveis de instância (`@plant`, `@care_logs`, etc.).
    *   **Integração Tailwind/JavaScript:** Se estiver renderizando uma view, ele envia HTML gerado por templates ERB/HAML. Se estiver lidando com uma requisição AJAX/Turbo, geralmente renderiza fragmentos específicos ou respostas Turbo Stream que os controladores Stimulus usarão para atualizar partes da página dinamicamente.
4.  **Modelos (`*`):** A lógica de negócio, validações e interações com o banco de dados ocorrem aqui (ex: `Plant.create!`, associações).
5.  **View (ERB/HTML):** O template renderiza as variáveis de instância preparadas em HTML. Esta saída inclui a estrutura estilizada pelo **Tailwind CSS**.

---

## 2. Gerenciamento de Plantas (CRUD)

O gerenciamento de plantas segue convenções RESTful padrão, mapeadas provavelmente em `config/routes.rb` para `plants#index`, `plants#show`, `plants#new`/`plants#create`, e `plants#edit`/`plants#update`/`plants#destroy`.

| Operação | Verbo HTTP | Caminho Provável | Ação do Controlador | Arquivo de View (Conceitual) | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Criação** | POST | `/plants` | `PlantsController#create` | `plants/new.html.erb` | Salva um novo registro de `Plant`. |
| **Leitura (Lista)** | GET | `/plants` | `PlantsController#index` | `plants/index.html.erb` | Exibe todas as plantas do jardim. |
| **Leitura (Detalhe)** | GET | `/plants/:id` | `PlantsController#show` | `plants/show.html.erb` | Exibe detalhes, incluindo o status de cuidado atual. |
| **Atualização** | PATCH/PUT | `/plants/:id` | `PlantsController#update` | `plants/edit.html.erb` | Modifica um registro de `Plant` existente. |
| **Deleção** | DELETE | `/plants/:id` | `PlantsController#destroy` | N/A (Redireciona) | Remove a planta e o histórico de cuidados associado. |

---

## 3. Sistema de Cuidados: Planta, Parâmetro e Log

O sistema de cuidados gira em torno de três modelos interconectados:

*   **`Plant`:** A entidade central. Possui muitas `CareParameters` e muitos `CareLogs`.
*   **`CareParameter`:** Define **o que** precisa ser feito e **com que frequência**.
    *   **Relação:** Pertence a uma `Plant`.
    *   **Dados:** Provavelmente armazena o tipo de cuidado (ex: "Rega", "Fertilização") e o intervalo (ex: 7 dias, 14 dias). Isso forma a base para o agendamento.
*   **`CareLog`:** Registra **quando** uma ação especificada por um `CareParameter` foi efetivamente realizada.
    *   **Relação:** Pertence a uma `Plant` e provavelmente referencia o `CareParameter` que disparou o registro.
    *   **Dados:** Armazena a `data da execução` e, opcionalmente, observações.

**Resumo do Fluxo:** O `CareParameter` define o **agendamento**, e o `CareLog` rastreia a **conformidade** com esse agendamento.

---

## 4. Fluxo de Notificação

O sistema de notificação é um processo assíncrono impulsionado principalmente por *jobs* em segundo plano (provavelmente Sidekiq ou similar, acionado por uma tarefa agendada).

1.  **`CareCalculatorService`:**
    *   **Função:** Responsável pela lógica de agendamento. Ele provavelmente é executado periodicamente (ex: diariamente via cron job).
    *   **Ação:** Ele consulta o banco de dados, comparando a data do último `CareLog` registrado com a data de vencimento calculada a partir do intervalo do `CareParameter` para cada planta ativa.
    *   **Saída:** Identifica tarefas que estão vencidas ou prestes a vencer.
2.  **`NotificationEngineService`:**
    *   **Função:** Agrega os achados do calculador.
    *   **Ação:** Agrupa as tarefas pendentes por usuário/combinação de planta. Determina o conteúdo final da mensagem, talvez agrupando múltiplas ações atrasadas para um único usuário em uma única notificação.
    *   **Saída:** Passa os *payloads* formatados para o serviço de entrega.
3.  **`Whatsapp::SendNotificationService`:**
    *   **Função:** Manipulador de comunicação externa.
    *   **Ação:** Pega a mensagem formatada do *engine* e utiliza a **API do WhatsApp** (via Evolution API) para despachar a mensagem.
    *   **Dependência:** Isso depende criticamente das credenciais e configurações armazenadas nas variáveis de ambiente lidas do arquivo `.env` (e `docker-compose.yml`).

---

## 5. Configuração do Ambiente (Docker/Ambiente)

A configuração do ambiente padroniza o desenvolvimento local e o deploy usando containers.

*   **`docker-compose.yml`:**
    *   **Função:** Define o ambiente de múltiplos containers, tipicamente incluindo serviços para a **aplicação Rails (web)**, um banco de dados **PostgreSQL**, e um processador de *jobs* em segundo plano (necessário para notificações). Ele gerencia a rede e o *volume mounting*.
*   **`docker-entrypoint.sh`:**
    *   **Função:** Executado quando o container do serviço Rails inicia.
    *   **Ação:** Provavelmente executa comandos essenciais de configuração, como `bundle install`, configuração do banco de dados (`rails db:create`, `rails db:migrate`), e, finalmente, inicia o servidor Rails (`rails server`).
*   **Variáveis `.env` (Específicas do WhatsApp):**
    *   O serviço de notificação via WhatsApp requer chaves de API e identificadores externos, que devem estar presentes no arquivo `.env` para funcionar. **Variáveis necessárias provavelmente incluem:**
        *   `EVOLUTION_API_URL`
        *   `EVOLUTION_INSTANCE`
        *   `EVOLUTION_API_KEY` (ou `AUTHENTICATION_API_KEY` dependendo da configuração)
        *   `USER_PHONE` (Número do usuário para envio)
        *   `RAILS_MASTER_KEY`

O arquivo `SYSTEM_FLOW_ANALYSIS.md` foi criado com sucesso no diretório raiz.
