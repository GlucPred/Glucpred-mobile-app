# Flujo Médico-Paciente - Documentación de Endpoints

## Descripción General

Este documento describe el flujo completo de interacción entre médicos y pacientes en el sistema GlucPred, incluyendo todos los endpoints necesarios para:

1. **Panel Principal del Médico**: Vista de resumen de todos los pacientes
2. **Vista Detallada del Paciente**: Estadísticas, gráficas y observaciones médicas
3. **Gestión de Observaciones Médicas**: Crear, leer, actualizar y eliminar notas

---

## Arquitectura de Servicios

### Punto de Entrada de la App Móvil

**IMPORTANTE**: La app móvil del médico **SOLO** se comunica con:

```
http://localhost:5000 (API Gateway)
```

Todos los endpoints documentados aquí se acceden a través del API Gateway en el puerto **5000**.

### Servicios Internos (No accesibles desde fuera)

Estos servicios se comunican entre sí dentro de la red Docker:

- **Doctor-Patient Service** (`http://doctor-patient-service:5000`): Gestión de relaciones y observaciones
- **Profile Service** (`http://profile-service:5000`): Información de perfiles
- **Records Service** (`http://records-service:5000`): Mediciones de glucosa
- **Alerts Service** (`http://alerts-service:5000`): Alertas críticas

### Base de Datos

- **doctor_patient_db** (Puerto 3313):
  - Tabla: `doctor_patient_relations` - Relaciones médico-paciente
  - Tabla: `medical_observations` - Observaciones médicas

---

## Flujo 1: Panel Principal del Médico

### Pantalla Mostrada
- Lista de todos los pacientes asignados al médico
- Por cada paciente:
  - Nombre completo
  - Estado (Estable / Moderada / Crítica)
  - Última glucosa medida
  - Cantidad de alertas críticas (últimas 24h)

### Endpoint Principal

#### `GET /api/doctor-patient/patients-summary`

**Descripción**: Obtiene resumen completo de todos los pacientes del médico autenticado.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response** (200 OK):
```json
{
  "doctor_user_id": 1,
  "total": 6,
  "patients": [
    {
      "patient_user_id": 5,
      "nombre_completo": "Ana Ruiz",
      "edad": 52,
      "ultima_glucosa": 245.0,
      "ultima_medicion_fecha": "2025-11-21T09:15:00",
      "estado": "Critica",
      "alertas_count": 2,
      "fecha_asignacion": "2025-10-01T10:00:00"
    },
    {
      "patient_user_id": 8,
      "nombre_completo": "Diana Hu...",
      "edad": 45,
      "ultima_glucosa": 136.0,
      "estado": "Critica",
      "alertas_count": 2,
      "fecha_asignacion": "2025-09-15T08:30:00"
    },
    {
      "patient_user_id": 12,
      "nombre_completo": "Luis Vega",
      "edad": 38,
      "ultima_glucosa": 168.0,
      "estado": "Moderada",
      "alertas_count": 1,
      "fecha_asignacion": "2025-11-10T14:20:00"
    },
    {
      "patient_user_id": 3,
      "nombre_completo": "Ana Sofía",
      "edad": 52,
      "ultima_glucosa": 245.0,
      "estado": "Estable",
      "alertas_count": 0,
      "fecha_asignacion": "2025-08-20T11:00:00"
    }
  ]
}
```

**Lógica de Estado**:
- `Critica`: ≥ 3 alertas críticas en últimas 24h
- `Moderada`: 1-2 alertas críticas en últimas 24h
- `Estable`: 0 alertas críticas

**Ordenamiento**: Los pacientes se ordenan por:
1. Estado (Crítica → Moderada → Estable)
2. Cantidad de alertas (descendente)

---

## Flujo 2: Vista Detallada del Paciente

### Pantalla Mostrada
- **Información del Paciente**:
  - Nombre completo, edad, estado actual
- **Mediciones**:
  - Glucosa actual
  - Promedio diario
  - % en rango objetivo
- **Tendencia (Gráfica)**:
  - Valores de glucosa en el tiempo (Hoy/Semana/Mes)
  - Zonas de riesgo visualizadas
- **Observación Médica**:
  - Campo de texto para escribir observación
  - Botón "Guardar cambios"
- **Historial de Observaciones**:
  - Lista de observaciones previas con fechas

### Endpoint Principal

#### `GET /api/doctor-patient/patient/{patient_user_id}/detail`

**Descripción**: Obtiene información completa del paciente para vista detallada del médico.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Query Parameters**:
- `period` (opcional): `day` | `week` | `month` (default: `day`)

**Response** (200 OK):
```json
{
  "patient_user_id": 5,
  "profile": {
    "user_id": 5,
    "nombre_completo": "Ana Sofía",
    "edad": 52,
    "peso": 68.5,
    "altura": 165,
    "genero": "F",
    "medicamentos": "Metformina 850mg, Insulina Glargina",
    "antecedentes": "Diabetes tipo 2, Hipertensión",
    "fecha_diagnostico": "2018-03-15"
  },
  "glucose_stats": {
    "average": 178.0,
    "min": 98.0,
    "max": 245.0,
    "in_range_percentage": 64.0,
    "total_readings": 48,
    "period": "day"
  },
  "glucose_trend": [
    {
      "id": 123,
      "glucose_value": 98.0,
      "measurement_time": "2025-11-21T00:00:00",
      "classification": "normal"
    },
    {
      "id": 124,
      "glucose_value": 115.0,
      "measurement_time": "2025-11-21T04:00:00",
      "classification": "normal"
    },
    {
      "id": 125,
      "glucose_value": 132.0,
      "measurement_time": "2025-11-21T08:00:00",
      "classification": "normal"
    },
    {
      "id": 126,
      "glucose_value": 158.0,
      "measurement_time": "2025-11-21T12:00:00",
      "classification": "alto"
    },
    {
      "id": 127,
      "glucose_value": 245.0,
      "measurement_time": "2025-11-21T16:00:00",
      "classification": "critico"
    }
  ],
  "latest_observation": {
    "id": 42,
    "doctor_user_id": 1,
    "patient_user_id": 5,
    "observation_text": "Control estable, mantener dosis actual.",
    "created_at": "2025-10-03T10:00:00",
    "updated_at": "2025-10-03T10:00:00"
  }
}
```

**Notas**:
- Si `latest_observation` es `null`, significa que el médico aún no ha escrito ninguna observación
- `glucose_trend` contiene hasta 50 mediciones más recientes del periodo seleccionado

---

## Flujo 3: Gestión de Observaciones Médicas

### 3.1. Crear Observación

#### `POST /api/doctor-patient/patient/{patient_user_id}/observations`

**Descripción**: Crea una nueva observación médica para el paciente.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Body**:
```json
{
  "observation_text": "Control estable, mantener dosis actual."
}
```

**Response** (201 Created):
```json
{
  "message": "Observación creada exitosamente",
  "observation": {
    "id": 42,
    "doctor_user_id": 1,
    "patient_user_id": 5,
    "observation_text": "Control estable, mantener dosis actual.",
    "created_at": "2025-11-21T09:15:00",
    "updated_at": "2025-11-21T09:15:00"
  }
}
```

---

### 3.2. Obtener Historial de Observaciones

#### `GET /api/doctor-patient/patient/{patient_user_id}/observations`

**Descripción**: Obtiene todas las observaciones médicas del paciente escritas por el médico autenticado.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Query Parameters**:
- `limit` (opcional): Número de resultados (default: 100)
- `offset` (opcional): Desplazamiento para paginación (default: 0)

**Response** (200 OK):
```json
{
  "patient_user_id": 5,
  "total": 4,
  "limit": 100,
  "offset": 0,
  "observations": [
    {
      "id": 45,
      "doctor_user_id": 1,
      "patient_user_id": 5,
      "observation_text": "Control estable, mantener dosis actual.",
      "created_at": "2025-10-03T10:00:00",
      "updated_at": "2025-10-03T10:00:00"
    },
    {
      "id": 38,
      "doctor_user_id": 1,
      "patient_user_id": 5,
      "observation_text": "Ajuste de medicación, programar seguimiento.",
      "created_at": "2025-08-05T14:30:00",
      "updated_at": "2025-08-05T14:30:00"
    },
    {
      "id": 32,
      "doctor_user_id": 1,
      "patient_user_id": 5,
      "observation_text": "Ajuste de medicación, programar monitoreo.",
      "created_at": "2025-07-22T09:00:00",
      "updated_at": "2025-07-22T09:00:00"
    },
    {
      "id": 25,
      "doctor_user_id": 1,
      "patient_user_id": 5,
      "observation_text": "Paciente refiere mejora, continuar monitoreo.",
      "created_at": "2025-07-03T11:15:00",
      "updated_at": "2025-07-03T11:15:00"
    }
  ]
}
```

**Nota**: Las observaciones están ordenadas por fecha de creación (más recientes primero).

---

### 3.3. Actualizar Observación

#### `PUT /api/doctor-patient/observations/{observation_id}`

**Descripción**: Actualiza una observación médica existente. Solo el médico que creó la observación puede editarla.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Body**:
```json
{
  "observation_text": "Control estable, mantener dosis actual y revisar en 1 mes."
}
```

**Response** (200 OK):
```json
{
  "message": "Observación actualizada exitosamente",
  "observation": {
    "id": 42,
    "doctor_user_id": 1,
    "patient_user_id": 5,
    "observation_text": "Control estable, mantener dosis actual y revisar en 1 mes.",
    "created_at": "2025-10-03T10:00:00",
    "updated_at": "2025-11-21T09:20:00"
  }
}
```

---

### 3.4. Eliminar Observación

#### `DELETE /api/doctor-patient/observations/{observation_id}`

**Descripción**: Elimina una observación médica. Solo el médico que creó la observación puede eliminarla.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response** (200 OK):
```json
{
  "message": "Observación eliminada exitosamente"
}
```

**Errores**:
- `403 Forbidden`: Si intentas eliminar una observación de otro médico
- `404 Not Found`: Si la observación no existe

---

## Flujo 4: Gestión de Relación Médico-Paciente

### 4.1. Asignar Paciente a Médico

#### `POST /api/doctor-patient/assign`

**Descripción**: Asigna un paciente al médico autenticado.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Body**:
```json
{
  "patient_user_id": 5
}
```

**Response** (201 Created):
```json
{
  "message": "Paciente asignado exitosamente",
  "relation": {
    "id": 12,
    "doctor_user_id": 1,
    "patient_user_id": 5,
    "estado": "A",
    "fecha_asignacion": "2025-11-21T09:00:00",
    "fecha_inactivacion": null,
    "created_at": "2025-11-21T09:00:00",
    "updated_at": "2025-11-21T09:00:00"
  }
}
```

**Reglas de Negocio**:
- Un paciente solo puede estar activamente asignado a UN médico a la vez
- Si el paciente ya está asignado a otro médico, retorna error 400
- Si la relación médico-paciente existe pero está inactiva, se reactiva

---

### 4.2. Desactivar Relación Médico-Paciente

#### `POST /api/doctor-patient/deactivate`

**Descripción**: Desactiva la relación con un paciente (deja de atenderlo).

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Body**:
```json
{
  "patient_user_id": 5
}
```

**Response** (200 OK):
```json
{
  "message": "Relación desactivada exitosamente",
  "relation": {
    "id": 12,
    "doctor_user_id": 1,
    "patient_user_id": 5,
    "estado": "I",
    "fecha_asignacion": "2025-11-21T09:00:00",
    "fecha_inactivacion": "2025-11-21T10:30:00",
    "created_at": "2025-11-21T09:00:00",
    "updated_at": "2025-11-21T10:30:00"
  }
}
```

---

### 4.3. Obtener Mis Pacientes

#### `GET /api/doctor-patient/my-patients`

**Descripción**: Obtiene lista de pacientes asignados al médico (sin detalles completos).

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Query Parameters**:
- `estado` (opcional): `A` (activos) | `I` (inactivos)

**Response** (200 OK):
```json
{
  "doctor_user_id": 1,
  "total": 6,
  "patients": [
    {
      "id": 12,
      "doctor_user_id": 1,
      "patient_user_id": 5,
      "estado": "A",
      "fecha_asignacion": "2025-11-21T09:00:00",
      "fecha_inactivacion": null,
      "created_at": "2025-11-21T09:00:00",
      "updated_at": "2025-11-21T09:00:00"
    }
  ]
}
```

**Nota**: Este endpoint retorna solo las relaciones. Para obtener detalles completos (nombre, glucosa, alertas), usar `/patients-summary`.

---

## Diagrama de Flujo Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                   App Móvil del Médico                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              1. PANTALLA PRINCIPAL DEL MÉDICO                   │
│                                                                 │
│  Endpoint: GET /api/doctor-patient/patients-summary             │
│                                                                 │
│  Muestra:                                                       │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ Ana Ruiz      [Critica]    245 mg/dL    2 alertas     │   │
│  │ Diana Hu...   [Critica]    136 mg/dL    2 alertas     │   │
│  │ Luis Vega     [Moderada]   168 mg/dL    1 alerta      │   │
│  │ Ana Sofía     [Estable]    245 mg/dL    0 alertas     │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Al hacer clic en lupa (🔍) → Navega a pantalla detallada     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│         2. PANTALLA DETALLADA DEL PACIENTE (Ana Sofía)         │
│                                                                 │
│  Endpoint: GET /api/doctor-patient/patient/5/detail?period=day  │
│                                                                 │
│  Muestra:                                                       │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ Nombre: Ana Sofía                   Edad: 52          │   │
│  │ Estado: [Estable]                                      │   │
│  │                                                         │   │
│  │ Glucosa actual: 245 mg/dL                              │   │
│  │ Promedio diario: 178 mg/dL                             │   │
│  │ % en rango objetivo: 64%                               │   │
│  │                                                         │   │
│  │ [Gráfica de Tendencia - Últimas 24 horas]             │   │
│  │  300 ┤                                        ●        │   │
│  │  250 ┤                                                 │   │
│  │  200 ┤                              ●                  │   │
│  │  150 ┤                    ●                            │   │
│  │  100 ┤        ●     ●                                  │   │
│  │   50 ┤  ●                                              │   │
│  │    0 └─────────────────────────────────────────────── │   │
│  │      0h   4h   8h   12h  16h  20h  24h                │   │
│  │                                                         │   │
│  │ Observación médica:                                    │   │
│  │ ┌─────────────────────────────────────────────────┐  │   │
│  │ │ Escribe una observación...                      │  │   │
│  │ │                                                 │  │   │
│  │ └─────────────────────────────────────────────────┘  │   │
│  │                                                         │   │
│  │ [Guardar cambios]                                      │   │
│  │                                                         │   │
│  │ [Historial] →                                          │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Al hacer clic en "Guardar cambios":                           │
│    POST /api/doctor-patient/patient/5/observations              │
│                                                                 │
│  Al hacer clic en "Historial":                                 │
│    Navega a pantalla de historial de observaciones             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│           3. PANTALLA HISTORIAL DE OBSERVACIONES                │
│                                                                 │
│  Endpoint: GET /api/doctor-patient/patient/5/observations       │
│                                                                 │
│  Muestra:                                                       │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ 📅 03/10/2025                                    [🗑️]  │   │
│  │ Control estable, mantener dosis actual.                │   │
│  │                                                         │   │
│  │ 📅 05/08/2025                                    [🗑️]  │   │
│  │ Ajuste de medicación, programar seguimiento.           │   │
│  │                                                         │   │
│  │ 📅 22/07/2025                                    [🗑️]  │   │
│  │ Ajuste de medicación, programar monitoreo.             │   │
│  │                                                         │   │
│  │ 📅 03/07/2025                                    [🗑️]  │   │
│  │ Paciente refiere mejora, continuar monitoreo.          │   │
│  │                                                         │   │
│  │                                              [➕ Nueva] │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Al hacer clic en 🗑️:                                          │
│    DELETE /api/doctor-patient/observations/{id}                 │
│                                                                 │
│  Al hacer clic en una observación:                             │
│    Permite editar con PUT /api/doctor-patient/observations/{id} │
└─────────────────────────────────────────────────────────────────┘
```

---

## Resumen de Endpoints por Pantalla

### Pantalla Principal del Médico
```
GET /api/doctor-patient/patients-summary
```

### Pantalla Detallada del Paciente
```
GET /api/doctor-patient/patient/{patient_user_id}/detail?period=day
POST /api/doctor-patient/patient/{patient_user_id}/observations
```

### Pantalla Historial de Observaciones
```
GET /api/doctor-patient/patient/{patient_user_id}/observations
PUT /api/doctor-patient/observations/{observation_id}
DELETE /api/doctor-patient/observations/{observation_id}
```

### Gestión de Relaciones (Administración)
```
POST /api/doctor-patient/assign
POST /api/doctor-patient/deactivate
GET /api/doctor-patient/my-patients
```

---

## Autenticación

Todos los endpoints requieren autenticación JWT con rol de `doctor`.

**Header requerido**:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Validación**:
- El middleware `@doctor_required` valida que el token sea válido
- Verifica que el usuario tenga rol `doctor`
- Extrae `user_id` del token y lo pasa a los servicios

---

## Códigos de Error Comunes

| Código | Descripción |
|--------|-------------|
| 200 | OK - Petición exitosa |
| 201 | Created - Recurso creado exitosamente |
| 400 | Bad Request - Datos inválidos o faltantes |
| 401 | Unauthorized - Token inválido o no proporcionado |
| 403 | Forbidden - No tienes permiso (rol incorrecto o sin acceso al paciente) |
| 404 | Not Found - Recurso no encontrado |
| 500 | Internal Server Error - Error del servidor |

---

## Notas Técnicas

### Comunicación entre Microservicios

El `doctor-patient-service` hace llamadas HTTP a otros servicios para obtener datos completos:

1. **Profile Service**: Obtiene nombre, edad, medicamentos del paciente
2. **Records Service**: Obtiene última glucosa, estadísticas y tendencias
3. **Alerts Service**: Obtiene cantidad de alertas críticas

**Timeout**: 3 segundos por servicio para evitar bloqueos prolongados

**Manejo de Errores**: Si un servicio no responde, el campo correspondiente será `null` o valor por defecto, pero la petición no falla.

### Base de Datos

**Tablas en `doctor_patient_db`**:

1. **doctor_patient_relations**:
   - `id` (PK)
   - `doctor_user_id` (FK → authentication-service)
   - `patient_user_id` (FK → authentication-service)
   - `estado` ('A' = Activo, 'I' = Inactivo)
   - `fecha_asignacion`
   - `fecha_inactivacion`
   - `created_at`
   - `updated_at`

2. **medical_observations**:
   - `id` (PK)
   - `doctor_user_id` (FK → authentication-service)
   - `patient_user_id` (FK → authentication-service)
   - `observation_text` (TEXT)
   - `created_at`
   - `updated_at`

---

## Ejemplo de Flujo Completo

**Base URL para todos los endpoints**: `http://localhost:5000`

### 1. Médico abre la app

```http
GET http://localhost:5000/api/doctor-patient/patients-summary
Authorization: Bearer <token>
```

**Respuesta**: Lista de 6 pacientes ordenados por criticidad

---

### 2. Médico hace clic en "Ana Sofía"

```http
GET http://localhost:5000/api/doctor-patient/patient/5/detail?period=day
Authorization: Bearer <token>
```

**Respuesta**: Perfil completo, estadísticas del día, gráfica con 48 mediciones, última observación

---

### 3. Médico escribe observación: "Control estable, mantener dosis actual."

```http
POST http://localhost:5000/api/doctor-patient/patient/5/observations
Authorization: Bearer <token>
Content-Type: application/json

{
  "observation_text": "Control estable, mantener dosis actual."
}
```

**Respuesta**: Observación creada con ID 42

---

### 4. Médico hace clic en "Historial"

```http
GET http://localhost:5000/api/doctor-patient/patient/5/observations
Authorization: Bearer <token>
```

**Respuesta**: 4 observaciones ordenadas por fecha (más reciente primero)

---

### 5. Médico edita la observación del 03/10/2025

```http
PUT http://localhost:5000/api/doctor-patient/observations/42
Authorization: Bearer <token>
Content-Type: application/json

{
  "observation_text": "Control estable, mantener dosis actual y revisar en 1 mes."
}
```

**Respuesta**: Observación actualizada

---

## Próximos Pasos de Implementación

1. ✅ Crear modelo `MedicalObservation`
2. ✅ Crear servicios de observaciones y resumen de pacientes
3. ✅ Implementar endpoints en `doctor-patient-service`
4. ✅ Actualizar API Gateway con nuevos endpoints
5. ⏳ Rebuild `doctor-patient-service` y `api-gateway`
6. ⏳ Crear migración de base de datos para `medical_observations`
7. ⏳ Probar flujo completo con Postman
8. ⏳ Integrar con app móvil del médico

---

## Contacto y Soporte

Para dudas o issues con este flujo, contactar al equipo de desarrollo de GlucPred.

**Última actualización**: 21 de noviembre de 2025
