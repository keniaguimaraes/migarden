## Why

Grid de cards dificulta consulta rapida quando ha muitas plantas. Tabela permite escanear nome, status e proximas datas em linha — mais eficiente para listas com 10+ plantas.

## What Changes

- Substituir `_plant_card` grid por tabela responsiva no `index.html.erb`
- Manter empty state (sem plantas)
- Ajustar targets Turbo Stream: `plants_grid` → `plants_table`, `plant_card_<id>` → `plant_row_<id>`
- Ajustar CSS: remover `.plant-grid`/`.plant-card` classes, adicionar `.plant-table` e estilos de tabela responsiva
- Controller `index` inalterado (ja retorna dados necessarios)

## Capabilities

### New Capabilities
- `plant-listing`: Listagem de plantas em tabela com colunas de nome, tipo, sol, proximas datas, status e acoes

### Modified Capabilities
Nenhuma — listagem atual nao possui spec formal.

## Impact

- `app/views/plants/index.html.erb` — reescrito
- `app/views/plants/_plant_card.html.erb` — removido (ou mantido se usado em outro lugar; verificar)
- `app/assets/stylesheets/application.css` — adicionar estilos de tabela, remover `.plant-grid`/`.plant-card`
- Targets Turbo Stream nos controllers/views — atualizar ids
- Nenhum impacto em modelo, banco, rotas ou dependencias
