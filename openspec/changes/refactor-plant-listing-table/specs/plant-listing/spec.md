## ADDED Requirements

### Requirement: Listagem em tabela responsiva
A pagina `plants#index` DEVE exibir plantas do usuario atual em formato de tabela HTML responsiva, substituindo o grid de cards atual.

#### Scenario: Usuario com plantas ve tabela
- **WHEN** usuario acessa `/plants` e possui plantas cadastradas
- **THEN** sistema exibe uma tabela com uma linha por planta

#### Scenario: Usuario sem plantas ve empty state
- **WHEN** usuario acessa `/plants` e nao possui plantas cadastradas
- **THEN** sistema exibe mensagem "Nenhuma planta ainda" com CTA para cadastrar

#### Scenario: Navegacao para nova planta
- **WHEN** usuario clica em "Nova planta"
- **THEN** sistema abre modal de cadastro (via `plant_modal` Turbo Frame)

### Requirement: Colunas da tabela
A tabela DEVE conter as seguintes colunas: Nome (com status), Tipo, Exposicao solar, Prox. Rega, Prox. Fertilizacao, Prox. Pragas, Acoes.

#### Scenario: Linha exibe dados corretos da planta
- **WHEN** planta possui nome "Jiboia", tipo "Folhagem", sol "meia_sombra"
- **THEN** linha mostra "Jiboia", "Folhagem", icone de meia sombra, e as proximas datas formatadas (dd/mm/aaaa)

#### Scenario: Coluna Nome linka para show da planta
- **WHEN** usuario clica no nome da planta
- **THEN** sistema redireciona para `/plants/:id`

#### Scenario: Data de cuidado atrasada tem destaque visual
- **WHEN** `next_watering_date` <= data atual
- **THEN** celula da coluna "Prox. Rega" exibe classe de destaque (cor warning/danger)

#### Scenario: Status badge aparece ao lado do nome
- **WHEN** planta precisa de qualquer cuidado
- **THEN** badge "Precisa de cuidado" (cor danger) aparece ao lado do nome
- **WHEN** planta esta em dia
- **THEN** badge "Em dia" (cor success) aparece ao lado do nome

### Requirement: Acoes por linha
Cada linha DEVE conter botoes/links para Editar e Excluir a planta.

#### Scenario: Clique em Editar abre modal
- **WHEN** usuario clica em "Editar" na linha
- **THEN** sistema abre modal de edicao (via `plant_modal` Turbo Frame)

#### Scenario: Clique em Excluir confirma e remove
- **WHEN** usuario clica em "Excluir" na linha
- **THEN** sistema exibe confirmacao e remove a planta apos confirmacao

### Requirement: Compatibilidade com Turbo Streams
A listagem DEVE continuar funcionando com updates via Turbo Stream apos criar/editar/excluir plantas.

#### Scenario: Criacao de planta atualiza tabela via Turbo Stream
- **WHEN** usuario cria nova planta com sucesso
- **THEN** sistema faz append da nova linha ao `#plants_table` e atualiza contador `#plants_count`

#### Scenario: Edicao de planta atualiza linha via Turbo Stream
- **WHEN** usuario edita planta com sucesso
- **THEN** sistema substitui a linha `#plant_row_<id>` e atualiza contador

#### Scenario: Exclusao remove linha via Turbo Stream
- **WHEN** usuario exclui planta com sucesso
- **THEN** sistema remove a linha `#plant_row_<id>` e atualiza contador
