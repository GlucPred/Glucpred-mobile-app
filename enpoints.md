# Endpoints para App Móvil - GlucPred

## Base URL
```
http://localhost:5000
```

## Swagger UI (Documentación Interactiva)
```
http://localhost:5000/
```

---

## 1. AUTENTICACIÓN

### 1.1 Registro de Usuario
```http
POST /api/auth/register
```

**Request Body:**
```json
{
  "nombre_completo": "Juan Pérez García",
  "username": "juanperez",
  "email": "juan.perez@example.com",
  "numero_celular": "+51987654321",
  "password": "Password123!",
  "confirmar_password": "Password123!",
  "rol": "Paciente"
}
```

**Campos:**
- `nombre_completo`: Nombre completo del usuario (obligatorio)
- `username`: Nombre de usuario único (obligatorio)
- `email`: Correo electrónico único (obligatorio)
- `numero_celular`: Número de celular con código de país (opcional)
- `password`: Contraseña (obligatorio)
- `confirmar_password`: Confirmación de contraseña (obligatorio)
- `rol`: "Paciente" o "Medico" (default: "Paciente")

**Response (201):**
```json
{
  "message": "Usuario registrado exitosamente",
  "user": {
    "id": 1,
    "nombre_completo": "Juan Pérez García",
    "username": "juanperez",
    "email": "juan.perez@example.com",
    "numero_celular": "+51987654321",
    "rol": "Paciente",
    "primer_inicio_sesion": true,
    "created_at": "2025-11-21T10:30:00"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### 1.2 Login
```http
POST /api/auth/login
```

**Request Body:**
```json
{
  "username": "juanperez",
  "password": "Password123!"
}
```

**Nota:** El campo `username` puede ser el username o el email.

**Response (200):**
```json
{
  "message": "Login exitoso",
  "user": {
    "id": 1,
    "nombre_completo": "Juan Pérez García",
    "username": "juanperez",
    "email": "juan.perez@example.com",
    "numero_celular": "+51987654321",
    "rol": "Paciente",
    "primer_inicio_sesion": false,
    "created_at": "2025-11-21T10:30:00"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**⚠️ Guardar el `access_token` - Se usa en todas las siguientes peticiones**

---

## 2. PERFIL DE PACIENTE

### 2.1 Crear Perfil
```http
POST /api/profile/paciente
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request Body (todos los campos opcionales):**
```json
{
  "edad": 35,
  "peso": 75.5,
  "altura": 170,
  "medicamentos": "Metformina 850mg, Insulina glargina 20UI",
  "antecedentes": "Diabetes tipo 2 desde 2020, hipertensión controlada",
  "fecha_diagnostico": "2020-01-15"
}
```

**Campos:**
- `edad`: Edad en años (int, opcional)
- `peso`: Peso en kilogramos (float, opcional)
- `altura`: Altura en centímetros (float, opcional)
- `medicamentos`: Medicamentos actuales (string, opcional)
- `antecedentes`: Antecedentes médicos (string, opcional)
- `fecha_diagnostico`: Fecha de diagnóstico formato YYYY-MM-DD (string, opcional)

**Response (201):**
```json
{
  "message": "Perfil creado exitosamente",
  "profile": {
    "id": 1,
    "user_id": 1,
    "edad": 35,
    "peso": 75.5,
    "altura": 170,
    "imc": 25.4,
    "medicamentos": "Metformina 850mg, Insulina glargina 20UI",
    "antecedentes": "Diabetes tipo 2 desde 2020, hipertensión controlada",
    "fecha_diagnostico": "2020-01-15",
    "created_at": "2025-11-21T10:35:00",
    "updated_at": "2025-11-21T10:35:00"
  }
}
```

**Nota:** El `imc` (Índice de Masa Corporal) se calcula automáticamente.

---

### 2.2 Obtener Perfil
```http
GET /api/profile/paciente
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200):**
```json
{
  "profile": {
    "id": 1,
    "user_id": 1,
    "edad": 35,
    "peso": 75.5,
    "altura": 170,
    "imc": 25.4,
    "medicamentos": "Metformina 850mg, Insulina glargina 20UI",
    "antecedentes": "Diabetes tipo 2 desde 2020, hipertensión controlada",
    "fecha_diagnostico": "2020-01-15",
    "created_at": "2025-11-21T10:35:00",
    "updated_at": "2025-11-21T10:35:00"
  }
}
```

---

### 2.3 Actualizar Perfil
```http
PUT /api/profile/paciente
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request Body (todos los campos opcionales):**
```json
{
  "peso": 74.0,
  "medicamentos": "Metformina 850mg, Insulina glargina 22UI"
}
```

**Response (200):**
```json
{
  "message": "Perfil actualizado exitosamente",
  "profile": {
    "id": 1,
    "user_id": 1,
    "edad": 35,
    "peso": 74.0,
    "altura": 170,
    "imc": 25.6,
    "medicamentos": "Metformina 850mg, Insulina glargina 22UI",
    "antecedentes": "Diabetes tipo 2 desde 2020, hipertensión controlada",
    "fecha_diagnostico": "2020-01-15",
    "created_at": "2025-11-21T10:35:00",
    "updated_at": "2025-11-21T11:20:00"
  }
}
```

---

## 3. REGISTROS DE GLUCOSA (CGM)

### 3.1 Crear Registro de Glucosa
```http
POST /api/records
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request Body:**
```json
{
  "glucose_value": 120.5,
  "measurement_time": "2025-11-21T14:30:00Z"
}
```

**Campos:**
- `glucose_value`: Valor de glucosa en mg/dL (float, obligatorio)
- `measurement_time`: Timestamp de la medición en formato ISO 8601 (string, opcional - default: hora actual)

**Response (201):**
```json
{
  "message": "Registro de glucosa creado exitosamente",
  "record": {
    "id": 1,
    "user_id": 1,
    "glucose_value": 120.5,
    "measurement_time": "2025-11-21T14:30:00",
    "classification": "normal",
    "created_at": "2025-11-21T14:30:15"
  }
}
```

**Clasificaciones automáticas:**
- `bajo`: < 70 mg/dL (Hipoglucemia)
- `normal`: 70-140 mg/dL
- `alto`: 140-180 mg/dL
- `critico`: > 180 mg/dL (Hiperglucemia crítica)

**Nota:** Esta clasificación genera automáticamente alertas mediante eventos Kafka.

---

### 3.2 Obtener Última Lectura
```http
GET /api/records/latest
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200):**
```json
{
  "id": 1,
  "user_id": 1,
  "glucose_value": 120.5,
  "measurement_time": "2025-11-21T14:30:00",
  "classification": "normal",
  "created_at": "2025-11-21T14:30:15"
}
```

---

### 3.3 Obtener Tendencia de Glucosa
```http
GET /api/records/trend?hours=12
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Query Parameters:**
- `hours`: Número de horas hacia atrás (int, default: 12, max: 720 [30 días])

**Response (200):**
```json
{
  "user_id": 1,
  "period_hours": 12,
  "records": [
    {
      "id": 1,
      "user_id": 1,
      "glucose_value": 95.0,
      "measurement_time": "2025-11-21T02:30:00",
      "classification": "normal",
      "created_at": "2025-11-21T02:30:10"
    },
    {
      "id": 2,
      "user_id": 1,
      "glucose_value": 120.5,
      "measurement_time": "2025-11-21T14:30:00",
      "classification": "normal",
      "created_at": "2025-11-21T14:30:15"
    }
  ],
  "total": 2
}
```

---

### 3.4 Obtener Historial Paginado
```http
GET /api/records/history?limit=100&offset=0&start_date=2025-11-01T00:00:00Z&end_date=2025-11-21T23:59:59Z
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Query Parameters:**
- `limit`: Registros por página (int, default: 100, max: 500)
- `offset`: Desplazamiento para paginación (int, default: 0)
- `start_date`: Fecha inicio ISO 8601 (string, opcional)
- `end_date`: Fecha fin ISO 8601 (string, opcional)

**Response (200):**
```json
{
  "user_id": 1,
  "records": [
    {
      "id": 1,
      "user_id": 1,
      "glucose_value": 120.5,
      "measurement_time": "2025-11-21T14:30:00",
      "classification": "normal",
      "created_at": "2025-11-21T14:30:15"
    }
  ],
  "total": 1,
  "limit": 100,
  "offset": 0,
  "has_more": false
}
```

---

### 3.5 Obtener Estadísticas
```http
GET /api/records/statistics?hours=24
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Query Parameters:**
- `hours`: Período en horas (int, default: 24, max: 720)

**Response (200):**
```json
{
  "user_id": 1,
  "period_hours": 24,
  "statistics": {
    "count": 48,
    "average": 115.2,
    "min": 85.0,
    "max": 165.0,
    "std_dev": 18.5,
    "time_in_range": {
      "low": 5.2,
      "normal": 87.5,
      "high": 7.3,
      "critical": 0.0
    }
  }
}
```

---

### 3.6 Eliminar Registro
```http
DELETE /api/records/{record_id}
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200):**
```json
{
  "message": "Registro eliminado exitosamente"
}
```

---

## 4. PREDICCIÓN DE EPISODIOS (ANÁLISIS ML)

### 4.1 Predecir Episodio de Glucosa
```http
POST /api/analysis/predict
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request Body:**
```json
{
  "glucose": 120.5,
  "insulin_30min": 5.0,
  "carbs_30min": 45.0,
  "heart_rate": 75.0,
  "steps_15min": 150,
  "calories_15min": 50.0,
  "hour": 14
}
```

**Campos:**
- `glucose`: Nivel actual de glucosa en mg/dL (float, obligatorio)
- `insulin_30min`: Insulina administrada en últimos 30 min en unidades (float, obligatorio)
- `carbs_30min`: Carbohidratos consumidos en últimos 30 min en gramos (float, obligatorio)
- `heart_rate`: Frecuencia cardíaca actual en bpm (float, opcional, default: 70) - **Desde Health Connect**
- `steps_15min`: Pasos en últimos 15 min (int, opcional, default: 50) - **Desde Health Connect**
- `calories_15min`: Calorías quemadas en últimos 15 min en kcal (float, opcional, default: 5) - **Desde Health Connect**
- `hour`: Hora del día 0-23 (int, opcional, default: hora actual)

**Response (200):**
```json
{
  "prediction": "Normal",
  "probabilities": {
    "Hipoglucemia": 0.05,
    "Normal": 0.90,
    "Hiperglucemia": 0.05
  },
  "alert_level": "Bajo",
  "recommendation": "Continuar con monitoreo regular. Nivel de glucosa estable.",
  "input_summary": {
    "glucose": 120.5,
    "insulin_30min": 5.0,
    "carbs_30min": 45.0,
    "heart_rate": 75.0,
    "steps_15min": 150,
    "calories_15min": 50.0,
    "hour": 14
  }
}
```

**Ejemplo con alerta alta (Hiperglucemia):**
```json
{
  "prediction": "Hiperglucemia",
  "probabilities": {
    "Hipoglucemia": 0.02,
    "Normal": 0.15,
    "Hiperglucemia": 0.83
  },
  "alert_level": "Alto",
  "recommendation": "⚠️ Riesgo alto de hiperglucemia. Considere ajustar medicación y evitar carbohidratos.",
  "input_summary": {
    "glucose": 185.0,
    "insulin_30min": 0.0,
    "carbs_30min": 80.0,
    "heart_rate": 82.0,
    "steps_15min": 20,
    "calories_15min": 3.0,
    "hour": 20
  }
}
```

**Valores posibles para `prediction`:**
- `Hipoglucemia`: Predicción de glucosa baja en próximos 10 minutos
- `Normal`: Predicción de glucosa normal
- `Hiperglucemia`: Predicción de glucosa alta en próximos 10 minutos

**Valores posibles para `alert_level`:**
- `Bajo`: Sin riesgo inmediato (probabilidad < 0.6)
- `Medio`: Riesgo moderado (probabilidad 0.6-0.8)
- `Alto`: Riesgo alto (probabilidad > 0.8)

**Comportamiento del sistema:**
- Si `alert_level != "Bajo"`, se publica automáticamente un evento Kafka `prediction.created`
- El servicio de alertas consume este evento y crea una alerta en la base de datos
- La alerta aparecerá en `GET /api/alerts` con `type: "prediction"`


---

## 5. ALERTAS

### 5.1 Obtener Alertas
```http
GET /api/alerts?type=todas&severity=critico&is_read=false&limit=100&offset=0
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Query Parameters:**
- `type`: Tipo de alerta (string, opcional)
  - `critica`: Alertas críticas de glucosa (hiper/hipoglucemia)
  - `recordatorio`: Recordatorios manuales
  - `todas`: Todas las alertas (default)
- `severity`: Severidad (string, opcional)
  - `critico`: Requiere atención inmediata
  - `advertencia`: Requiere precaución
  - `info`: Informativo
- `is_read`: Estado de lectura (string, opcional)
  - `true`: Solo alertas leídas
  - `false`: Solo alertas no leídas
  - No especificar: Todas
- `limit`: Registros por página (int, default: 100)
- `offset`: Desplazamiento para paginación (int, default: 0)

**Response (200):**
```json
{
  "alerts": [
    {
      "id": 1,
      "user_id": 1,
      "glucose_record_id": 15,
      "glucose_value": 195.0,
      "alert_type": "critica",
      "severity": "critico",
      "title": "Hiperglucemia detectada",
      "message": "Revisar medicación y consultar médico.",
      "is_read": false,
      "is_dismissed": false,
      "created_at": "2025-11-21T14:45:00",
      "read_at": null,
      "dismissed_at": null
    },
    {
      "id": 2,
      "user_id": 1,
      "glucose_record_id": 12,
      "glucose_value": 65.0,
      "alert_type": "critica",
      "severity": "advertencia",
      "title": "Hipoglucemia leve",
      "message": "Consumir 15g de carbohidratos rápidos.",
      "is_read": true,
      "is_dismissed": false,
      "created_at": "2025-11-21T11:20:00",
      "read_at": "2025-11-21T11:25:00",
      "dismissed_at": null
    }
  ],
  "total": 2,
  "limit": 100,
  "offset": 0,
  "has_more": false
}
```

**Tipos de alertas generadas automáticamente:**
1. **Hiperglucemia crítica** (>180 mg/dL):
   - `severity: "critico"`
   - `title: "Hiperglucemia detectada"`
   - `message: "Revisar medicación y consultar médico."`

2. **Hiperglucemia alta** (140-180 mg/dL):
   - `severity: "advertencia"`
   - `title: "Glucosa elevada"`
   - `message: "Nivel de glucosa alto. Monitorear y evitar carbohidratos."`

3. **Hipoglucemia crítica** (<50 mg/dL):
   - `severity: "critico"`
   - `title: "Hipoglucemia severa"`
   - `message: "Consumir 15g de carbohidratos rápidos inmediatamente."`

4. **Hipoglucemia leve** (50-70 mg/dL):
   - `severity: "advertencia"`
   - `title: "Hipoglucemia leve"`
   - `message: "Consumir 15g de carbohidratos rápidos."`

---

### 5.2 Obtener Conteo de Alertas No Leídas
```http
GET /api/alerts/unread-count
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200):**
```json
{
  "unread_count": 3
}
```

---

### 5.3 Obtener Conteo de Alertas Críticas
```http
GET /api/alerts/critical-count?hours=24
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Query Parameters:**
- `hours`: Período en horas (int, default: 24)

**Response (200):**
```json
{
  "critical_count": 2,
  "period_hours": 24
}
```

---

### 5.4 Marcar Alerta como Leída
```http
PUT /api/alerts/{alert_id}/read
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200):**
```json
{
  "message": "Alerta marcada como leída",
  "alert": {
    "id": 1,
    "user_id": 1,
    "glucose_record_id": 15,
    "glucose_value": 195.0,
    "alert_type": "critica",
    "severity": "critico",
    "title": "Hiperglucemia detectada",
    "message": "Revisar medicación y consultar médico.",
    "is_read": true,
    "is_dismissed": false,
    "created_at": "2025-11-21T14:45:00",
    "read_at": "2025-11-21T14:50:00",
    "dismissed_at": null
  }
}
```

---

### 5.5 Marcar Todas las Alertas como Leídas
```http
PUT /api/alerts/read-all
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200):**
```json
{
  "message": "3 alertas marcadas como leídas",
  "count": 3
}
```

---

### 5.6 Descartar/Eliminar Alerta
```http
DELETE /api/alerts/{alert_id}
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200):**
```json
{
  "message": "Alerta descartada exitosamente"
}
```

---

### 5.7 Crear Recordatorio Manual
```http
POST /api/alerts/reminder
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request Body:**
```json
{
  "title": "Tomar medicación",
  "message": "Recuerda tomar tu insulina de la noche"
}
```

**Response (201):**
```json
{
  "message": "Recordatorio creado exitosamente",
  "alert": {
    "id": 5,
    "user_id": 1,
    "glucose_record_id": null,
    "glucose_value": null,
    "alert_type": "recordatorio",
    "severity": "info",
    "title": "Tomar medicación",
    "message": "Recuerda tomar tu insulina de la noche",
    "is_read": false,
    "is_dismissed": false,
    "created_at": "2025-11-21T20:00:00",
    "read_at": null,
    "dismissed_at": null
  }
}
```


---

## 6. INTEGRACIÓN CON HEALTH CONNECT

### Flujo de Trabajo Recomendado (Cada 5 minutos con WorkManager)

#### 1. Configurar WorkManager en Android

```kotlin
// En Application class
class GlucPredApp : Application(), Configuration.Provider {
    override fun onCreate() {
        super.onCreate()
        
        // Programar análisis periódico cada 5 minutos
        val workRequest = PeriodicWorkRequestBuilder<GlucoseAnalysisWorker>(
            15, TimeUnit.MINUTES, // Mínimo 15 minutos para PeriodicWork
            5, TimeUnit.MINUTES   // Flex interval
        )
        .setConstraints(
            Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()
        )
        .build()
        
        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "glucose_analysis",
            ExistingPeriodicWorkPolicy.KEEP,
            workRequest
        )
    }
}
```

#### 2. Implementar Worker para Análisis

```kotlin
class GlucoseAnalysisWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            // 1. Leer datos de Health Connect (últimos 15 min)
            val healthData = readHealthConnectData()
            
            // 2. Obtener última glucosa y datos nutricionales locales
            val glucoseData = getLocalGlucoseData()
            
            // 3. Enviar predicción al backend
            val prediction = apiService.predictEpisode(
                glucose = glucoseData.lastGlucose,
                insulin_30min = glucoseData.insulin30Min,
                carbs_30min = glucoseData.carbs30Min,
                heart_rate = healthData.avgHeartRate,
                steps_15min = healthData.totalSteps,
                calories_15min = healthData.totalCalories
            )
            
            // 4. Mostrar notificación si hay alerta
            if (prediction.alert_level != "Bajo") {
                showPredictionNotification(prediction)
            }
            
            Result.success()
        } catch (e: Exception) {
            Log.e("GlucoseWorker", "Error en análisis", e)
            Result.retry()
        }
    }
    
    private suspend fun readHealthConnectData(): HealthData {
        val healthConnectClient = HealthConnectClient.getOrCreate(applicationContext)
        val now = Instant.now()
        val startTime = now.minus(15, ChronoUnit.MINUTES)
        
        // Leer frecuencia cardíaca
        val heartRateRequest = ReadRecordsRequest(
            recordType = HeartRateRecord::class,
            timeRangeFilter = TimeRangeFilter.between(startTime, now)
        )
        val heartRateRecords = healthConnectClient.readRecords(heartRateRequest)
        val avgHeartRate = heartRateRecords.records
            .mapNotNull { it.samples.firstOrNull()?.beatsPerMinute }
            .average()
            .takeIf { !it.isNaN() } ?: 70.0
        
        // Leer pasos
        val stepsRequest = ReadRecordsRequest(
            recordType = StepsRecord::class,
            timeRangeFilter = TimeRangeFilter.between(startTime, now)
        )
        val stepsRecords = healthConnectClient.readRecords(stepsRequest)
        val totalSteps = stepsRecords.records.sumOf { it.count.toInt() }
        
        // Leer calorías
        val caloriesRequest = ReadRecordsRequest(
            recordType = TotalCaloriesBurnedRecord::class,
            timeRangeFilter = TimeRangeFilter.between(startTime, now)
        )
        val caloriesRecords = healthConnectClient.readRecords(caloriesRequest)
        val totalCalories = caloriesRecords.records
            .sumOf { it.energy.inKilocalories }
        
        return HealthData(
            avgHeartRate = avgHeartRate,
            totalSteps = totalSteps,
            totalCalories = totalCalories
        )
    }
    
    private suspend fun getLocalGlucoseData(): GlucoseData {
        val db = GlucPredDatabase.getInstance(applicationContext)
        val now = System.currentTimeMillis()
        val thirtyMinAgo = now - (30 * 60 * 1000)
        
        return GlucoseData(
            lastGlucose = db.glucoseDao().getLatest()?.value ?: 100.0,
            insulin30Min = db.insulinDao().getSumSince(thirtyMinAgo),
            carbs30Min = db.nutritionDao().getCarbsSince(thirtyMinAgo)
        )
    }
}

data class HealthData(
    val avgHeartRate: Double,
    val totalSteps: Int,
    val totalCalories: Double
)

data class GlucoseData(
    val lastGlucose: Double,
    val insulin30Min: Double,
    val carbs30Min: Double
)
```

#### 3. Solicitar Permisos de Health Connect

```kotlin
// En Activity o Fragment
class HealthConnectSetupActivity : ComponentActivity() {
    
    private val HEALTH_CONNECT_PERMISSIONS = setOf(
        HealthPermission.getReadPermission(HeartRateRecord::class),
        HealthPermission.getReadPermission(StepsRecord::class),
        HealthPermission.getReadPermission(TotalCaloriesBurnedRecord::class)
    )
    
    private val requestPermissions = registerForActivityResult(
        PermissionController.createRequestPermissionResultContract()
    ) { granted ->
        if (granted.containsAll(HEALTH_CONNECT_PERMISSIONS)) {
            Toast.makeText(this, "Permisos concedidos", Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this, "Se requieren todos los permisos", Toast.LENGTH_SHORT).show()
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        lifecycleScope.launch {
            val healthConnectClient = HealthConnectClient.getOrCreate(this@HealthConnectSetupActivity)
            val granted = healthConnectClient.permissionController
                .getGrantedPermissions()
            
            if (!granted.containsAll(HEALTH_CONNECT_PERMISSIONS)) {
                requestPermissions.launch(HEALTH_CONNECT_PERMISSIONS)
            }
        }
    }
}
```

#### 4. Almacenamiento Local con Room

```kotlin
@Entity(tableName = "glucose_readings")
data class GlucoseReading(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val value: Double,
    val timestamp: Long,
    val classification: String, // "bajo", "normal", "alto", "critico"
    val synced: Boolean = false
)

@Entity(tableName = "insulin_doses")
data class InsulinDose(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val units: Double,
    val timestamp: Long,
    val type: String, // "rapida", "lenta"
    val synced: Boolean = false
)

@Entity(tableName = "nutrition_records")
data class NutritionRecord(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val carbs: Double,
    val protein: Double,
    val fat: Double,
    val timestamp: Long,
    val mealType: String, // "breakfast", "lunch", "dinner", "snack"
    val synced: Boolean = false
)

@Dao
interface GlucoseDao {
    @Query("SELECT * FROM glucose_readings ORDER BY timestamp DESC LIMIT 1")
    suspend fun getLatest(): GlucoseReading?
    
    @Query("SELECT * FROM glucose_readings WHERE synced = 0")
    suspend fun getUnsynced(): List<GlucoseReading>
    
    @Insert
    suspend fun insert(reading: GlucoseReading)
    
    @Update
    suspend fun update(reading: GlucoseReading)
}

@Dao
interface InsulinDao {
    @Query("SELECT SUM(units) FROM insulin_doses WHERE timestamp >= :since")
    suspend fun getSumSince(since: Long): Double
    
    @Insert
    suspend fun insert(dose: InsulinDose)
}

@Dao
interface NutritionDao {
    @Query("SELECT SUM(carbs) FROM nutrition_records WHERE timestamp >= :since")
    suspend fun getCarbsSince(since: Long): Double
    
    @Insert
    suspend fun insert(record: NutritionRecord)
}
```

#### 5. Sincronización con Backend

```kotlin
class SyncWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        val db = GlucPredDatabase.getInstance(applicationContext)
        val apiService = RetrofitClient.apiService
        
        try {
            // Sincronizar lecturas de glucosa no enviadas
            val unsyncedGlucose = db.glucoseDao().getUnsynced()
            unsyncedGlucose.forEach { reading ->
                val response = apiService.createGlucoseRecord(
                    GlucoseRecordRequest(
                        glucose_value = reading.value,
                        measurement_time = Instant.ofEpochMilli(reading.timestamp).toString()
                    )
                )
                
                if (response.isSuccessful) {
                    db.glucoseDao().update(reading.copy(synced = true))
                }
            }
            
            return Result.success()
        } catch (e: Exception) {
            Log.e("SyncWorker", "Error en sincronización", e)
            return Result.retry()
        }
    }
}
```

---

### Dependencias Gradle Necesarias

```gradle
dependencies {
    // Health Connect
    implementation("androidx.health.connect:connect-client:1.1.0-alpha07")
    
    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.0")
    
    // Room
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")
    
    // Retrofit
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    
    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
```

---

### Manifest Permissions

```xml
<manifest>
    <!-- Health Connect -->
    <uses-permission android:name="android.permission.health.READ_HEART_RATE" />
    <uses-permission android:name="android.permission.health.READ_STEPS" />
    <uses-permission android:name="android.permission.health.READ_TOTAL_CALORIES_BURNED" />
    
    <!-- Network -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application>
        <!-- Health Connect Provider -->
        <activity-alias
            android:name="ViewPermissionUsageActivity"
            android:exported="true"
            android:permission="android.permission.START_VIEW_PERMISSION_USAGE"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" />
            </intent-filter>
        </activity-alias>
    </application>
</manifest>
```


---

## 7. CÓDIGOS DE ERROR COMUNES

### 400 Bad Request
```json
{
  "error": "glucose_value es requerido"
}
```
**Causa:** Faltan campos obligatorios o formato inválido  
**Solución:** Verificar que todos los campos requeridos estén presentes y con el tipo correcto

---

### 401 Unauthorized
```json
{
  "error": "Token inválido o expirado"
}
```
**Causa:** Token JWT no válido, expirado o no enviado  
**Solución:** Volver a hacer login (`POST /api/auth/login`) y obtener un nuevo token

---

### 404 Not Found
```json
{
  "error": "Perfil no encontrado"
}
```
**Causa:** El recurso solicitado no existe  
**Solución:** Verificar que el ID sea correcto o crear el recurso si es necesario

---

### 409 Conflict
```json
{
  "error": "El correo electrónico ya está registrado"
}
```
**Causa:** Intento de crear un recurso que ya existe  
**Solución:** Usar datos únicos o actualizar el recurso existente

---

### 500 Internal Server Error
```json
{
  "error": "Error interno del servidor: ..."
}
```
**Causa:** Error en el servidor  
**Solución:** Reintentar después de unos segundos, contactar soporte si persiste

---

### 503 Service Unavailable
```json
{
  "error": "Model not loaded"
}
```
**Causa:** El modelo de ML del analysis-service no está cargado  
**Solución:** Verificar que el archivo `episode_predictor.joblib` exista en el servidor

---

## 8. EJEMPLO COMPLETO DE FLUJO

### Escenario: Nuevo usuario registra su primer día

#### Paso 1: Registro y Login
```bash
# 1. Registrar usuario
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nombre_completo": "María González",
    "username": "mariagonzalez",
    "email": "maria.gonzalez@example.com",
    "numero_celular": "+51987654321",
    "password": "Secure123!",
    "confirmar_password": "Secure123!",
    "rol": "Paciente"
  }'

# Respuesta:
# {
#   "message": "Usuario registrado exitosamente",
#   "user": {...},
#   "access_token": "eyJhbGc..."
# }

# Guardar el access_token
export TOKEN="eyJhbGc..."
```

---

#### Paso 2: Crear Perfil Médico
```bash
curl -X POST http://localhost:5000/api/profile/paciente \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "edad": 42,
    "peso": 68.5,
    "altura": 165,
    "medicamentos": "Metformina 850mg (2x día), Insulina glargina 18UI (noche)",
    "antecedentes": "Diabetes tipo 2 desde 2018, hipertensión controlada",
    "fecha_diagnostico": "2018-03-15"
  }'

# Respuesta:
# {
#   "message": "Perfil creado exitosamente",
#   "profile": {
#     "id": 1,
#     "user_id": 1,
#     "imc": 25.2,
#     ...
#   }
# }
```

---

#### Paso 3: Registrar Primera Lectura de Glucosa (del CGM)
```bash
curl -X POST http://localhost:5000/api/records \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "glucose_value": 135.0,
    "measurement_time": "2025-11-21T08:30:00Z"
  }'

# Respuesta:
# {
#   "message": "Registro de glucosa creado exitosamente",
#   "record": {
#     "id": 1,
#     "glucose_value": 135.0,
#     "classification": "normal",
#     ...
#   }
# }
```

---

#### Paso 4: Primera Predicción con Health Connect
```bash
# Supongamos que Health Connect leyó:
# - Heart rate: 72 bpm
# - Steps (últimos 15 min): 180 pasos
# - Calories (últimos 15 min): 12 kcal

# Y localmente guardaste:
# - Última glucosa: 135 mg/dL
# - Insulina (30 min): 6 unidades (antes del desayuno)
# - Carbohidratos (30 min): 50 gramos (desayuno)

curl -X POST http://localhost:5000/api/analysis/predict \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "glucose": 135.0,
    "insulin_30min": 6.0,
    "carbs_30min": 50.0,
    "heart_rate": 72.0,
    "steps_15min": 180,
    "calories_15min": 12.0,
    "hour": 8
  }'

# Respuesta:
# {
#   "prediction": "Normal",
#   "probabilities": {
#     "Hipoglucemia": 0.03,
#     "Normal": 0.92,
#     "Hiperglucemia": 0.05
#   },
#   "alert_level": "Bajo",
#   "recommendation": "Continuar con monitoreo regular. Nivel de glucosa estable.",
#   ...
# }
```

---

#### Paso 5: Simular Hiperglucemia y Ver Alerta
```bash
# Registrar glucosa alta (después del almuerzo)
curl -X POST http://localhost:5000/api/records \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "glucose_value": 195.0,
    "measurement_time": "2025-11-21T14:30:00Z"
  }'

# Esto genera automáticamente una alerta vía Kafka
# Esperar 2-3 segundos para que el consumer procese el evento

# Obtener alertas
curl -X GET "http://localhost:5000/api/alerts?is_read=false" \
  -H "Authorization: Bearer $TOKEN"

# Respuesta:
# {
#   "alerts": [
#     {
#       "id": 1,
#       "glucose_value": 195.0,
#       "alert_type": "critica",
#       "severity": "critico",
#       "title": "Hiperglucemia detectada",
#       "message": "Revisar medicación y consultar médico.",
#       "is_read": false,
#       ...
#     }
#   ],
#   "total": 1,
#   ...
# }
```

---

#### Paso 6: Marcar Alerta como Leída
```bash
curl -X PUT http://localhost:5000/api/alerts/1/read \
  -H "Authorization: Bearer $TOKEN"

# Respuesta:
# {
#   "message": "Alerta marcada como leída",
#   "alert": {
#     "id": 1,
#     "is_read": true,
#     "read_at": "2025-11-21T14:35:00",
#     ...
#   }
# }
```

---

#### Paso 7: Ver Tendencia del Día
```bash
curl -X GET "http://localhost:5000/api/records/trend?hours=12" \
  -H "Authorization: Bearer $TOKEN"

# Respuesta:
# {
#   "user_id": 1,
#   "period_hours": 12,
#   "records": [
#     {"glucose_value": 135.0, "classification": "normal", ...},
#     {"glucose_value": 195.0, "classification": "critico", ...}
#   ],
#   "total": 2
# }
```

---

#### Paso 8: Ver Estadísticas del Día
```bash
curl -X GET "http://localhost:5000/api/records/statistics?hours=24" \
  -H "Authorization: Bearer $TOKEN"

# Respuesta:
# {
#   "user_id": 1,
#   "period_hours": 24,
#   "statistics": {
#     "count": 2,
#     "average": 165.0,
#     "min": 135.0,
#     "max": 195.0,
#     "std_dev": 30.0,
#     "time_in_range": {
#       "low": 0.0,
#       "normal": 50.0,
#       "high": 0.0,
#       "critical": 50.0
#     }
#   }
# }
```

---

## 9. ARQUITECTURA Y FLUJO DE EVENTOS

### Diagrama de Flujo de Datos

```
┌─────────────┐
│  App Móvil  │
└──────┬──────┘
       │
       │ POST /api/records (glucose_value)
       ▼
┌──────────────────┐
│   API Gateway    │──────► Auth Middleware (JWT)
└──────┬───────────┘
       │ Forward request
       ▼
┌──────────────────┐
│ Records Service  │──────► Clasifica glucosa
└──────┬───────────┘        (bajo/normal/alto/critico)
       │
       │ Publica evento "glucose.recorded"
       ▼
┌──────────────────┐
│   Apache Kafka   │
│  (event-bus)     │
└──────┬───────────┘
       │
       │ Consume evento
       ▼
┌──────────────────┐
│  Alerts Service  │──────► Genera alerta si necesario
└──────┬───────────┘        (hiperglucemia/hipoglucemia)
       │
       │ Guarda en DB
       ▼
┌──────────────────┐
│   MySQL DB       │
│  (alerts-db)     │
└──────────────────┘
       │
       │ App consulta GET /api/alerts
       ▼
┌─────────────┐
│  App Móvil  │──────► Muestra notificación
└─────────────┘
```

### Flujo de Predicción ML

```
┌─────────────┐
│  App Móvil  │──────► WorkManager (cada 5 min)
└──────┬──────┘
       │
       │ Lee Health Connect:
       │ - Heart rate
       │ - Steps (15 min)
       │ - Calories (15 min)
       │
       │ Lee datos locales:
       │ - Última glucosa
       │ - Insulina (30 min)
       │ - Carbohidratos (30 min)
       │
       │ POST /api/analysis/predict
       ▼
┌──────────────────┐
│   API Gateway    │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Analysis Service │──────► XGBoost Model
└──────┬───────────┘        (53 features)
       │                    97% F1-Score
       │
       │ Si alert_level != "Bajo"
       │ Publica "prediction.created"
       ▼
┌──────────────────┐
│   Apache Kafka   │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Alerts Service  │──────► Genera alerta predictiva
└──────────────────┘
```

---

## 10. NOTAS TÉCNICAS

### Modelo de Machine Learning
- **Algoritmo:** XGBoost Classifier
- **F1-Score Macro:** 97%
- **Features de entrada:** 6 (glucose, insulin_30min, carbs_30min, heart_rate, steps_15min, calories_15min)
- **Features generadas:** 53 (automáticamente mediante feature engineering)
- **Clases predichas:** 
  - Hipoglucemia (glucosa < 70 mg/dL en próximos 10 min)
  - Normal (glucosa 70-180 mg/dL)
  - Hiperglucemia (glucosa > 180 mg/dL en próximos 10 min)
- **Archivo del modelo:** `analysis-service/models/episode_predictor.joblib`

### Clasificación de Glucosa (CGM)
- **Bajo (Hipoglucemia):** < 70 mg/dL
- **Normal:** 70-140 mg/dL
- **Alto:** 140-180 mg/dL
- **Crítico:** > 180 mg/dL

### Eventos Kafka

**Topic:** `event-bus`

**Eventos publicados:**

1. **glucose.recorded** (Records Service)
```json
{
  "event_type": "glucose.recorded",
  "user_id": 1,
  "record_id": 15,
  "glucose_value": 195.0,
  "classification": "critico",
  "measurement_time": "2025-11-21T14:30:00Z",
  "timestamp": "2025-11-21T14:30:15Z"
}
```

2. **prediction.created** (Analysis Service)
```json
{
  "event_type": "prediction.created",
  "user_id": 1,
  "prediction": "Hiperglucemia",
  "alert_level": "Alto",
  "probabilities": {
    "Hipoglucemia": 0.02,
    "Normal": 0.15,
    "Hiperglucemia": 0.83
  },
  "recommendation": "⚠️ Riesgo alto de hiperglucemia...",
  "glucose": 185.0,
  "insulin_30min": 0.0,
  "carbs_30min": 80.0,
  "timestamp": "2025-11-21T20:15:00Z"
}
```

3. **profile.created** (Profile Service)
```json
{
  "event_type": "profile.created",
  "user_id": 1,
  "profile_data": {...},
  "timestamp": "2025-11-21T10:35:00Z"
}
```

### Microservicios y Puertos

| Servicio | Puerto | Base de Datos | Puerto DB |
|----------|--------|---------------|-----------|
| API Gateway | 5000 | - | - |
| Authentication | 5002 | auth-db | 3307 |
| Profile | 5003 | profile-db | 3308 |
| Records | 5004 | records-db | 3311 |
| Alerts | 5005 | alerts-db | 3312 |
| Analysis | 5001 | - | - |
| Doctor-Patient | 5006 | doctor-patient-db | 3309 |
| Doctor-Profile | 5007 | doctor-profile-db | 3310 |
| Kafka | 9092 | - | - |
| Zookeeper | 2181 | - | - |

### Frecuencia Recomendada
- **Lecturas CGM:** Cada 5 minutos (automático del sensor)
- **Predicciones ML:** Cada 5-15 minutos (WorkManager)
- **Sincronización Health Connect:** Cada 15 minutos
- **Sincronización con backend:** Cuando hay conexión (WorkManager con NetworkType.CONNECTED)

### Almacenamiento Local (Recomendado)
Para garantizar funcionamiento offline y reducir latencia:

1. **Room Database (SQLite):**
   - Tabla `glucose_readings`: Lecturas del CGM
   - Tabla `insulin_doses`: Dosis de insulina
   - Tabla `nutrition_records`: Registros de comidas
   - Tabla `predictions`: Cache de predicciones ML
   - Tabla `alerts`: Cache de alertas del servidor

2. **Sincronización:**
   - Guardar todos los datos localmente primero
   - Sincronizar con backend cuando haya conexión
   - Marcar registros como `synced = true` después de enviar
   - Mostrar indicador de sincronización pendiente en UI

3. **Caché:**
   - Cachear perfil de usuario
   - Cachear últimas 24h de glucosa para gráficos
   - Cachear configuraciones de la app

### Health Connect
- **API:** Android Health Connect 1.1.0
- **Permisos necesarios:**
  - `READ_HEART_RATE`: Frecuencia cardíaca
  - `READ_STEPS`: Pasos
  - `READ_TOTAL_CALORIES_BURNED`: Calorías quemadas
- **Ventana de lectura:** Últimos 15 minutos para análisis cada 5 min
- **Fallback:** Si no hay datos de Health Connect, usar valores default (heart_rate: 70, steps: 50, calories: 5)

---

## 11. SEGURIDAD Y MEJORES PRÁCTICAS

### Autenticación JWT
- **Header:** `Authorization: Bearer {token}`
- **Expiración:** Configurable en el servidor (típicamente 24 horas)
- **Renovación:** Re-login cuando el token expira
- **Almacenamiento:** Usar `EncryptedSharedPreferences` en Android

```kotlin
// Guardar token de forma segura
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val sharedPreferences = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)

sharedPreferences.edit()
    .putString("access_token", token)
    .apply()
```

### Validación de Datos
- **Cliente (App):** Validar antes de enviar
- **Servidor:** Validar siempre (nunca confiar en cliente)
- **Tipos:** Verificar tipos de datos (int, float, string)
- **Rangos:** Glucosa (0-600 mg/dL), Insulina (0-100 UI), Carbs (0-500 g)

### Manejo de Errores
```kotlin
sealed class ApiResult<T> {
    data class Success<T>(val data: T) : ApiResult<T>()
    data class Error<T>(val message: String, val code: Int) : ApiResult<T>()
    data class NetworkError<T>(val exception: Exception) : ApiResult<T>()
}

suspend fun <T> safeApiCall(apiCall: suspend () -> Response<T>): ApiResult<T> {
    return try {
        val response = apiCall()
        if (response.isSuccessful) {
            ApiResult.Success(response.body()!!)
        } else {
            ApiResult.Error(
                response.errorBody()?.string() ?: "Error desconocido",
                response.code()
            )
        }
    } catch (e: IOException) {
        ApiResult.NetworkError(e)
    } catch (e: Exception) {
        ApiResult.Error(e.message ?: "Error inesperado", -1)
    }
}
```

### Retry Logic
```kotlin
// Para análisis periódico con WorkManager
class GlucoseAnalysisWorker(...) : CoroutineWorker(...) {
    override suspend fun doWork(): Result {
        return try {
            // Lógica de análisis
            Result.success()
        } catch (e: IOException) {
            // Error de red - reintentar
            if (runAttemptCount < 3) {
                Result.retry()
            } else {
                Result.failure()
            }
        } catch (e: Exception) {
            // Otro error - fallar
            Log.e("Worker", "Error", e)
            Result.failure()
        }
    }
}
```

---

## 12. CONTACTO Y SOPORTE

**API Gateway:** http://localhost:5000  
**Swagger Docs:** http://localhost:5000/  
**Analysis Service Health:** http://localhost:5001/api/analysis/health  
**Records Service Health:** http://localhost:5004/api/records/health  

**Repositorio Backend:** https://github.com/GlucPred/Glucpred-Backend  
**Branch:** `test`

---

## 13. CHANGELOG

### v1.0.0 (2025-11-21)
- Documentación inicial completa
- Endpoints de autenticación, perfil, records, alerts, analysis
- Integración con Health Connect
- Ejemplos de código Kotlin
- Arquitectura de eventos Kafka
- Mejores prácticas de seguridad
