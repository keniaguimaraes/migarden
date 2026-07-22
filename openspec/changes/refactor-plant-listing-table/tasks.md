## 1. View — Tabela no index

- [x] 1.1 Reescrever `app/views/plants/index.html.erb`: substituir `.plant-grid` / render `plant_card` por `<table id="plants_table">` com `<thead>` (Nome, Tipo, Sol, Prox. Rega, Prox. Fertilizacao, Prox. Pragas, Acoes) e `<tbody>` iterando `@plants`
- [x] 1.2 Criar partial `app/views/plants/_plant_row.html.erb` com `<tr id="plant_row_<%= plant.id %>">` contendo celulas: nome (com link + status badge), tipo, sol (icone + label), proximas datas (com classe `attention` se atrasada), acoes (editar modal, excluir com confirmacao)
- [x] 1.3 Atualizar `index.html.erb` para renderizar `plant_row` no `<tbody>` e manter header "Nova planta" + contador + empty state

## 2. Controller — Turbo Stream targets

- [x] 2.1 Em `turbo_stream_create_response`: trocar `'plants_grid'` e `'plants/plant_card'` por `'plants_table'` e `'plants/plant_row'`
- [x] 2.2 Em `turbo_stream_update_response`: trocar `"plant_card_#{plant.id}"` e `'plants/plant_card'` por `"plant_row_#{plant.id}"` e `'plants/plant_row'`

## 3. Estilos CSS

- [x] 3.1 Adicionar estilos de tabela em `app/assets/stylesheets/application.css`: `.plant-table` (overflow-x auto), `.plant-table table` (largura 100%, collapse), th (texto muted, uppercase, tracking), td (padding vertical 12px), `.plant-table__name` (bold, link), `.plant-table__date--attention` (cor warning), `.plant-table__actions` (flex, gap, icones)
- [x] 3.2 Nao remover estilos `.plant-grid` / `.plant-card` — sao usados em dashboard e alerts

## 4. Verificacao

- [x] 4.1 Rodar `bin/rails server` e testar: listagem vazia → empty state, criar planta → linha aparece via Turbo, editar → linha atualiza, excluir → linha some
- [x] 4.2 Verificar dashboard e alerts continuam com cards intactos
