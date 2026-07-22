## Context

Listagem atual usa grid de cards (`_plant_card`) com foto, nome, tipo, proximas datas e acoes. Cards otimos para exibicao visual, mas ocupam muito espaco vertical e dificultam comparacao entre plantas. Usuario com 10+ plantas precisa escanear rapidamente.

Tabela resolve: cada linha = uma planta, colunas fixas permitem ordenacao mental por coluna.

Controller `index` ja retorna `@plants` com includes de `care_parameters`, `care_logs` e `photo_attachment` — suficiente para tabela.

## Goals / Non-Goals

**Goals:**
- Substituir grid de cards por tabela responsiva em `plants#index`
- Preservar empty state e fluxo de "Nova planta"
- Manter compatibilidade com Turbo Streams (append, replace, count update)
- Adicionar estilos de tabela usando paleta existente (branco gelo, verde musgo)

**Non-Goals:**
- Nao adicionar paginacao, busca ou filtros (fora do escopo)
- Nao alterar modelo de dados
- Nao alterar rotas ou controller
- Nao alterar show/edit/delete flows

## Decisions

### 1. Tabela simples vs componente tipo `datatable`
**Decisao:** Tabela HTML pura com CSS responsivo, sem biblioteca JS.

**Por que:** Nao ha necessidade de ordenacao por coluna, busca ou paginacao no escopo atual. Tabela pura e mais leve, sem dependencias extras. Futuramente pode-se adicionar filtering/sorting com JS se necessario.

### 2. Colunas da tabela

| Coluna | Conteudo | Nota |
|--------|----------|------|
| Nome | `plant.name` + badge de status | Link para show |
| Tipo | `plant.plant_type` | — |
| Sol | icone + `plant.sun_exposure_label` | — |
| Prox. Rega | `format_br_date(plant.next_watering_date)` | destaque se atrasado |
| Prox. Fertilizacao | `format_br_date(plant.next_fertilization_date)` | destaque se atrasado |
| Prox. Pragas | `format_br_date(plant.next_pest_control_date)` | destaque se atrasado |
| Acoes | Editar / Excluir | icones ou botoes compactos |

### 3. Foto removida da listagem
**Decisao:** Foto nao aparece na tabela para economizar espaco horizontal. Detalhe da planta (com foto) permanece na tela `show`.

**Por que:** Tabela prioriza informacao textual escaneavel. Foto ocupa espaco precioso em viewport estreita.

### 4. Responsividade via overflow horizontal
Tabela recebe `overflow-x: auto` em container para rolagem em telas estreitas. No mobile, usuario pode rolar horizontalmente.

Alternativa considerada: esconder colunas menos importantes em mobile. Rejeitada por adicionar complexidade de implementacao e possivel confusao.

### 5. Identificadores Turbo Stream
- `#plants_table` (substitui `#plants_grid`)
- `#plant_row_<id>` (substitui `#plant_card_<id>`)
- `#plants_count` mantido

### 6. Partial `_plant_card` mantido como backup
Nao remover o arquivo — pode ser usado em dashboard ou outras telas futuras. Apenas o `index.html.erb` deixa de renderiza-lo.

## Risks / Trade-offs

- **[Loss of visual appeal]** Tabela e menos convidativa que cards com foto → Mitigacao: usar cores de status e badges para manter apelo visual, header estilizado
- **[Overflow em telas muito estreitas]** 7 colunas podem exigir scroll horizontal → Mitigacao: colunas de data sao estreitas; nomes podem truncar com CSS `text-overflow: ellipsis`
- **[Turbo Streams]** Partials de Turbo Stream podem referenciar `plant_card` ainda → Mitigacao: revisar todas as ocorrencias de `plant_card` e `plants_grid` nos controllers e views que disparam Turbo Streams

## Open Questions

- `_plant_card` usado em outros lugares (dashboard, alerts)? Verificar antes de remover ou renomear.
- `_count` partial continua valida? Sim — referencia apenas `count`.
- Foto na tabela: incluir thumbnail pequena (40x40) ou nao? Decisao: nao, mantendo escaneabilidade.
