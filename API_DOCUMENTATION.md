# 🌿 API do miGarden - Documentação Completa

> **Status**: Disponível via REST API  
> **Base URL**: `https://seu-dominio.up.railway.app`  
> **Formato**: JSON  
> **Autenticação**: Não requerida (MVP)

---

## 📋 Endpoints Disponíveis

### 1. PLANTS (Plantas)

#### 🟢 GET /plants
**Listar todas as plantas**

```bash
curl https://seu-dominio.up.railway.app/plants
```

**Resposta (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Rosa Vermelha",
    "species": "Rosa",
    "nickname": "Rosa do jardim",
    "created_at": "2026-05-08T10:00:00Z",
    "updated_at": "2026-05-08T10:00:00Z"
  },
  {
    "id": 2,
    "name": "Orquídea",
    "species": "Phalaenopsis",
    "nickname": null,
    "created_at": "2026-05-08T10:30:00Z",
    "updated_at": "2026-05-08T10:30:00Z"
  }
]
```

---

#### 🟢 GET /plants/:id
**Ver detalhes de uma planta específica**

```bash
curl https://seu-dominio.up.railway.app/plants/1
```

**Resposta (200 OK):**
```json
{
  "id": 1,
  "name": "Rosa Vermelha",
  "species": "Rosa",
  "nickname": "Rosa do jardim",
  "created_at": "2026-05-08T10:00:00Z",
  "updated_at": "2026-05-08T10:00:00Z",
  "care_parameters": [
    {
      "id": 101,
      "plant_id": 1,
      "care_type": "watering",
      "frequency_days": 3,
      "created_at": "2026-05-08T10:05:00Z"
    }
  ]
}
```

---

#### 🔵 POST /plants
**Criar nova planta**

```bash
curl -X POST https://seu-dominio.up.railway.app/plants \
  -H "Content-Type: application/json" \
  -d '{
    "plant": {
      "name": "Rosa Vermelha",
      "species": "Rosa damascena",
      "nickname": "Rosa do jardim"
    }
  }'
```

**Resposta (201 Created):**
```json
{
  "id": 3,
  "name": "Rosa Vermelha",
  "species": "Rosa damascena",
  "nickname": "Rosa do jardim",
  "created_at": "2026-05-08T12:00:00Z",
  "updated_at": "2026-05-08T12:00:00Z"
}
```

**Campos obrigatórios:**
- `name` (string) - Nome da planta
- `species` (string) - Espécie botânica
- `nickname` (string, opcional) - Apelido/nome popular

---

#### 🟡 PATCH /plants/:id
**Atualizar planta existente**

```bash
curl -X PATCH https://seu-dominio.up.railway.app/plants/1 \
  -H "Content-Type: application/json" \
  -d '{
    "plant": {
      "name": "Rosa Pink",
      "nickname": "Rosa nova"
    }
  }'
```

**Resposta (200 OK):**
```json
{
  "id": 1,
  "name": "Rosa Pink",
  "species": "Rosa",
  "nickname": "Rosa nova",
  "created_at": "2026-05-08T10:00:00Z",
  "updated_at": "2026-05-08T12:05:00Z"
}
```

---

#### 🔴 DELETE /plants/:id
**Remover planta**

```bash
curl -X DELETE https://seu-dominio.up.railway.app/plants/1
```

**Resposta (204 No Content):**
```
(sem conteúdo - apenas status 204)
```

---

### 2. CARE PARAMETERS (Parâmetros de Cuidado)

#### 🟢 GET /plants/:plant_id/care_parameters
**Listar parâmetros de cuidado de uma planta**

```bash
curl https://seu-dominio.up.railway.app/plants/1/care_parameters
```

**Resposta (200 OK):**
```json
[
  {
    "id": 101,
    "plant_id": 1,
    "care_type": "watering",
    "frequency_days": 3,
    "last_performed_at": "2026-05-06T10:00:00Z",
    "created_at": "2026-05-08T10:05:00Z"
  },
  {
    "id": 102,
    "plant_id": 1,
    "care_type": "fertilizing",
    "frequency_days": 14,
    "last_performed_at": "2026-04-24T10:00:00Z",
    "created_at": "2026-05-08T10:06:00Z"
  }
]
```

---

#### 🔵 POST /plants/:plant_id/care_parameters
**Criar novo parâmetro de cuidado**

```bash
curl -X POST https://seu-dominio.up.railway.app/plants/1/care_parameters \
  -H "Content-Type: application/json" \
  -d '{
    "care_parameter": {
      "care_type": "watering",
      "frequency_days": 3
    }
  }'
```

**Tipos de cuidado disponíveis:**
- `watering` - Rega
- `fertilizing` - Fertilização
- `pruning` - Poda
- `repotting` - Replantio
- `pest_control` - Controle de pragas
- `misting` - Pulverização

**Resposta (201 Created):**
```json
{
  "id": 103,
  "plant_id": 1,
  "care_type": "watering",
  "frequency_days": 3,
  "created_at": "2026-05-08T12:00:00Z"
}
```

---

#### 🔴 DELETE /plants/:plant_id/care_parameters/:id
**Remover parâmetro de cuidado**

```bash
curl -X DELETE https://seu-dominio.up.railway.app/plants/1/care_parameters/103
```

**Resposta (204 No Content):**
```
(sem conteúdo - apenas status 204)
```

---

### 3. CARE LOGS (Registro de Cuidados)

#### 🔵 POST /care_logs
**Registrar que um cuidado foi realizado**

```bash
curl -X POST https://seu-dominio.up.railway.app/care_logs \
  -H "Content-Type: application/json" \
  -d '{
    "care_log": {
      "plant_id": 1,
      "care_type": "watering",
      "performed_at": "2026-05-08T10:30:00Z",
      "notes": "Regada normalmente"
    }
  }'
```

**Resposta (201 Created):**
```json
{
  "id": 501,
  "plant_id": 1,
  "care_type": "watering",
  "performed_at": "2026-05-08T10:30:00Z",
  "notes": "Regada normalmente",
  "created_at": "2026-05-08T10:30:00Z"
}
```

---

## 🧪 Exemplos de Uso Prático

### Exemplo 1: Criar uma planta com todos os cuidados

```bash
# 1. Criar planta
PLANT_ID=$(curl -X POST https://seu-dominio.up.railway.app/plants \
  -H "Content-Type: application/json" \
  -d '{
    "plant": {
      "name": "Suculenta",
      "species": "Aloe vera",
      "nickname": "Babosa"
    }
  }' | jq -r '.id')

echo "Planta criada com ID: $PLANT_ID"

# 2. Adicionar parâmetro de rega
curl -X POST https://seu-dominio.up.railway.app/plants/$PLANT_ID/care_parameters \
  -H "Content-Type: application/json" \
  -d '{
    "care_parameter": {
      "care_type": "watering",
      "frequency_days": 7
    }
  }'

# 3. Adicionar parâmetro de fertilização
curl -X POST https://seu-dominio.up.railway.app/plants/$PLANT_ID/care_parameters \
  -H "Content-Type: application/json" \
  -d '{
    "care_parameter": {
      "care_type": "fertilizing",
      "frequency_days": 30
    }
  }'

# 4. Registrar que foi regada hoje
curl -X POST https://seu-dominio.up.railway.app/care_logs \
  -H "Content-Type: application/json" \
  -d "{
    \"care_log\": {
      \"plant_id\": $PLANT_ID,
      \"care_type\": \"watering\",
      \"performed_at\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\"
    }
  }"
```

---

### Exemplo 2: Usar em JavaScript/Node.js

```javascript
// Listar todas as plantas
async function listPlants() {
  const response = await fetch('https://seu-dominio.up.railway.app/plants');
  const plants = await response.json();
  console.log(plants);
}

// Criar nova planta
async function createPlant(name, species) {
  const response = await fetch('https://seu-dominio.up.railway.app/plants', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      plant: {
        name: name,
        species: species
      }
    })
  });
  return await response.json();
}

// Registrar cuidado realizado
async function logCare(plantId, careType) {
  const response = await fetch('https://seu-dominio.up.railway.app/care_logs', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      care_log: {
        plant_id: plantId,
        care_type: careType,
        performed_at: new Date().toISOString()
      }
    })
  });
  return await response.json();
}

// Uso
listPlants();
const newPlant = await createPlant('Rosa', 'Rosa vermelha');
await logCare(newPlant.id, 'watering');
```

---

### Exemplo 3: Usar em Python

```python
import requests
import json
from datetime import datetime

BASE_URL = 'https://seu-dominio.up.railway.app'

# Listar plantas
def list_plants():
    response = requests.get(f'{BASE_URL}/plants')
    return response.json()

# Criar planta
def create_plant(name, species):
    data = {
        'plant': {
            'name': name,
            'species': species
        }
    }
    response = requests.post(
        f'{BASE_URL}/plants',
        headers={'Content-Type': 'application/json'},
        json=data
    )
    return response.json()

# Registrar cuidado
def log_care(plant_id, care_type):
    data = {
        'care_log': {
            'plant_id': plant_id,
            'care_type': care_type,
            'performed_at': datetime.utcnow().isoformat() + 'Z'
        }
    }
    response = requests.post(
        f'{BASE_URL}/care_logs',
        headers={'Content-Type': 'application/json'},
        json=data
    )
    return response.json()

# Uso
plants = list_plants()
print(plants)

new_plant = create_plant('Orquídea', 'Phalaenopsis')
log_care(new_plant['id'], 'watering')
```

---

## 🔍 Códigos HTTP

| Código | Significado | Exemplo |
|--------|-------------|---------|
| **200** | OK | GET /plants bem-sucedido |
| **201** | Created | POST planta criada |
| **204** | No Content | DELETE bem-sucedido |
| **400** | Bad Request | JSON inválido |
| **404** | Not Found | Planta não existe |
| **422** | Unprocessable Entity | Validação falhou |
| **500** | Server Error | Erro no servidor |

---

## ⚠️ Erros Comuns

### Erro: 422 Unprocessable Entity
```json
{
  "name": ["can't be blank"]
}
```
**Solução**: Verifique se enviou `name` no body

### Erro: 404 Not Found
```
{
  "error": "Plant not found"
}
```
**Solução**: Verifique se o ID existe: `GET /plants`

### Erro: 500 Internal Server Error
```
(erro genérico do servidor)
```
**Solução**: 
1. Verificar logs: `railroad app → Logs`
2. Confirmar variáveis de ambiente
3. Rodar migrations: `railway run bundle exec rails db:migrate`

---

## 📱 Casos de Uso

### 1. App Mobile
```
App → API REST → Rails → PostgreSQL → WhatsApp (Evolution API)
                   ↓
            Notificações automáticas
```

### 2. Dashboard Web
```
HTML/JavaScript → API JSON → Backend Rails
```

### 3. Automação (Bot/Webhook)
```
Webhook externo → POST /care_logs → Rails processa
```

### 4. Integração com IoT
```
Sensor de umidade → HTTP POST /care_logs → Rails
```

---

## 🔐 Segurança (Futuro)

Quando for para produção, adicionar:
- ✅ Autenticação com tokens JWT
- ✅ CORS configurado
- ✅ Rate limiting
- ✅ Validação de entrada
- ✅ HTTPS obrigatório

---

## 📚 Recursos Adicionais

- [Rails API Docs](https://guides.rubyonrails.org/api_documentation_guidelines.html)
- [REST API Best Practices](https://restfulapi.net/)
- [JSON Schema](https://json-schema.org/)

---

**API pronta para usar! 🚀**
