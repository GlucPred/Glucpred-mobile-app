# AlertsService - Guía de Uso

## Descripción General

El `AlertsService` gestiona el sistema de alertas y notificaciones de la aplicación GlucPred. Permite obtener, crear, marcar y eliminar alertas relacionadas con mediciones de glucosa y recordatorios manuales.

## Arquitectura del Sistema

El sistema de alertas funciona con un flujo automático basado en eventos:

```
1. Paciente registra glucosa → POST /api/records/
2. Records Service clasifica → bajo/normal/alto/critico  
3. Kafka publica evento → glucose.recorded
4. Alerts Service escucha → Crea alerta si es necesario
5. Paciente ve en app → NotificationsScreen
```

### Clasificación de Glucosa
- **Crítico**: > 180 mg/dL (hiperglucemia)
- **Alto**: 140-180 mg/dL
- **Normal**: 70-140 mg/dL
- **Bajo**: < 70 mg/dL (hipoglucemia)

## Tipos de Alertas

### 1. Alertas Críticas (`tipo: 'critica'`)
Generadas automáticamente por el sistema cuando:
- Glucosa > 180 mg/dL (hiperglucemia)
- Glucosa < 70 mg/dL (hipoglucemia)
- Tendencia peligrosa detectada

**Severidades:**
- `critico`: Requiere acción inmediata
- `advertencia`: Precaución necesaria
- `info`: Información relevante

### 2. Recordatorios (`tipo: 'recordatorio'`)
Creados manualmente por el usuario para:
- Recordar mediciones de glucosa
- Tomar medicamentos
- Citas médicas
- Ejercicio o comidas

## Métodos Disponibles

### 1. `getAlerts()`
Obtiene la lista de alertas con filtros opcionales.

```dart
final response = await AlertsService.getAlerts(
  type: 'todas',          // 'todas', 'critica', 'recordatorio'
  severity: 'critico',    // 'critico', 'advertencia', 'info' (opcional)
  isRead: false,          // true/false (opcional)
  limit: 50,              // Max resultados
  offset: 0,              // Para paginación
);

// Respuesta
{
  "success": true,
  "alerts": [
    {
      "id": 123,
      "user_id": 1,
      "tipo": "critica",
      "severidad": "critico",
      "titulo": "Hiperglucemia detectada",
      "mensaje": "Tu nivel de glucosa está en 195 mg/dL. Revisa tu medicación.",
      "is_read": false,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 10,
  "limit": 50,
  "offset": 0,
  "has_more": false
}
```

**Uso común:**
```dart
// Cargar todas las alertas no leídas
final unread = await AlertsService.getAlerts(
  type: 'todas',
  isRead: false,
);

// Solo alertas críticas
final critical = await AlertsService.getAlerts(
  type: 'critica',
);

// Solo recordatorios
final reminders = await AlertsService.getAlerts(
  type: 'recordatorio',
  limit: 10,
);
```

---

### 2. `getUnreadCount()`
Obtiene el número de alertas no leídas (para badge en UI).

```dart
final response = await AlertsService.getUnreadCount();

// Respuesta
{
  "success": true,
  "unread_count": 5
}

// Uso
int badge = response['unread_count'] ?? 0;
```

**Uso común:**
```dart
// En MainNavigation para mostrar badge
Future<void> _updateBadge() async {
  final result = await AlertsService.getUnreadCount();
  setState(() {
    _alertBadgeCount = result['unread_count'] ?? 0;
  });
}
```

---

### 3. `getCriticalCount()`
Obtiene el número de alertas críticas en las últimas X horas (útil para vista de médicos).

```dart
final response = await AlertsService.getCriticalCount(hours: 24);

// Respuesta
{
  "success": true,
  "critical_count": 3,
  "hours": 24
}
```

**Uso común:**
```dart
// En DoctorHomeScreen
final criticalAlerts = await AlertsService.getCriticalCount(hours: 24);
print('Alertas críticas últimas 24h: ${criticalAlerts['critical_count']}');
```

---

### 4. `markAsRead()`
Marca una alerta como leída.

```dart
final response = await AlertsService.markAsRead(alertId);

// Respuesta
{
  "success": true,
  "alert": { /* alerta actualizada */ },
  "message": "Alerta marcada como leída"
}
```

**Uso común:**
```dart
// Al hacer tap en una alerta
onTap: () async {
  await AlertsService.markAsRead(alert['id']);
  await _loadAlerts(); // Recargar lista
}
```

---

### 5. `markAllAsRead()`
Marca todas las alertas del usuario como leídas.

```dart
final response = await AlertsService.markAllAsRead();

// Respuesta
{
  "success": true,
  "updated_count": 5,
  "message": "5 alertas marcadas como leídas"
}
```

**Uso común:**
```dart
// Botón en AppBar
IconButton(
  icon: Icon(Icons.done_all),
  onPressed: () async {
    await AlertsService.markAllAsRead();
    await _loadAlerts();
  },
)
```

---

### 6. `dismissAlert()`
Elimina una alerta permanentemente.

```dart
final response = await AlertsService.dismissAlert(alertId);

// Respuesta
{
  "success": true,
  "message": "Alerta eliminada exitosamente"
}
```

**Uso común:**
```dart
// Con Dismissible widget
Dismissible(
  key: Key('alert_$alertId'),
  onDismissed: (direction) async {
    await AlertsService.dismissAlert(alertId);
  },
  child: AlertCard(...),
)
```

---

### 7. `createReminder()`
Crea un recordatorio manual.

```dart
final response = await AlertsService.createReminder(
  title: 'Medir glucosa',
  message: 'Es hora de tu medición de la tarde',
);

// Respuesta
{
  "success": true,
  "alert": {
    "id": 124,
    "tipo": "recordatorio",
    "severidad": "info",
    "titulo": "Medir glucosa",
    "mensaje": "Es hora de tu medición de la tarde",
    "is_read": false,
    "created_at": "2024-01-15T14:00:00Z"
  },
  "message": "Recordatorio creado exitosamente"
}
```

**Uso común:**
```dart
// FloatingActionButton para crear recordatorio
FloatingActionButton(
  onPressed: () async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => CreateReminderDialog(),
    );
    
    if (result != null) {
      await AlertsService.createReminder(
        title: result['title']!,
        message: result['message']!,
      );
      await _loadAlerts();
    }
  },
  child: Icon(Icons.add),
)
```

---

## Métodos Helper

### 1. `getColorBySeverity()`
Convierte severidad en Color de Flutter.

```dart
Color color = AlertsService.getColorBySeverity('critico');
// Retorna: Color(0xFFC72331) - Rojo

// Severidades:
// 'critico' → Rojo (0xFFC72331)
// 'advertencia' → Amarillo (0xFFFBC318)
// 'info' → Azul (0xFF0073E6)
// default → Gris (0xFF6C7C93)
```

### 2. `getIconByType()`
Convierte tipo en IconData de Flutter.

```dart
IconData icon = AlertsService.getIconByType('critica');
// Retorna: Icons.warning

// Tipos:
// 'critica' → Icons.warning
// 'recordatorio' → Icons.notifications
// default → Icons.info
```

### 3. `getTimeAgo()`
Formatea tiempo relativo.

```dart
String time = AlertsService.getTimeAgo('2024-01-15T10:30:00Z');
// Retorna: "Hace 2 horas"

// Ejemplos:
// < 1 min → "Hace un momento"
// < 60 min → "Hace X minutos"
// < 24h → "Hace X horas"
// < 7 días → "Hace X días"
// >= 7 días → "Hace X semanas"
```

---

## Ejemplos de Implementación Completa

### NotificationsScreen con Tabs

```dart
class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0;
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    
    String typeFilter = 'todas';
    if (_selectedTab == 1) typeFilter = 'critica';
    else if (_selectedTab == 2) typeFilter = 'recordatorio';
    
    final response = await AlertsService.getAlerts(
      type: typeFilter,
      limit: 50,
    );
    
    setState(() {
      _alerts = List<Map<String, dynamic>>.from(response['alerts'] ?? []);
      _isLoading = false;
    });
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final severity = alert['severidad'] ?? 'info';
    final type = alert['tipo'] ?? 'critica';
    
    final color = AlertsService.getColorBySeverity(severity);
    final icon = AlertsService.getIconByType(type);
    final timeAgo = AlertsService.getTimeAgo(alert['created_at']);
    
    return Dismissible(
      key: Key('alert_${alert['id']}'),
      onDismissed: (_) => AlertsService.dismissAlert(alert['id']),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(alert['titulo']),
          subtitle: Text(timeAgo),
          onTap: () => _markAsRead(alert['id']),
        ),
      ),
    );
  }

  Future<void> _markAsRead(int id) async {
    await AlertsService.markAsRead(id);
    await _loadAlerts();
  }
}
```

### Badge Counter en Navigation

```dart
class _MainNavigationState extends State<MainNavigation> {
  int _alertBadge = 0;

  @override
  void initState() {
    super.initState();
    _updateAlertBadge();
  }

  Future<void> _updateAlertBadge() async {
    final result = await AlertsService.getUnreadCount();
    setState(() {
      _alertBadge = result['unread_count'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('$_alertBadge'),
            isLabelVisible: _alertBadge > 0,
            child: Icon(Icons.notifications),
          ),
          label: 'Alertas',
        ),
      ],
    );
  }
}
```

---

## Manejo de Errores

Todos los métodos retornan un mapa con la clave `success`:

```dart
try {
  final response = await AlertsService.getAlerts();
  
  if (response['success'] == true) {
    // Operación exitosa
    final alerts = response['alerts'];
    setState(() => _alerts = alerts);
  } else {
    // Error del servidor
    final errorMsg = response['message'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMsg)),
    );
  }
} catch (e) {
  // Error de conexión
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error de conexión: $e')),
  );
}
```

---

## Estados de las Alertas

### Estado `is_read`
- `false`: Alerta nueva (sin leer)
  - Color de fondo destacado
  - Borde con color de severidad
  - Fuente en negrita
- `true`: Alerta leída
  - Color de fondo normal
  - Sin borde
  - Fuente normal

### Visual Indicators

```dart
Card(
  color: isRead 
    ? null 
    : Color(0xFFF0F7FF), // Azul claro para no leídas
  shape: RoundedRectangleBorder(
    side: isRead 
      ? BorderSide.none 
      : BorderSide(color: severityColor.withOpacity(0.3)),
  ),
)
```

---

## Buenas Prácticas

### 1. Actualización de UI
```dart
// ✅ Correcto: Recargar después de acciones
await AlertsService.markAsRead(id);
await _loadAlerts(); // Refresca la lista

// ❌ Incorrecto: No actualizar
await AlertsService.markAsRead(id);
// La UI queda desactualizada
```

### 2. Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: _loadAlerts,
  child: ListView.builder(
    itemCount: _alerts.length,
    itemBuilder: (context, index) => _buildAlertCard(_alerts[index]),
  ),
)
```

### 3. Confirmación antes de eliminar
```dart
confirmDismiss: (direction) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Eliminar alerta'),
      content: Text('¿Deseas eliminar esta alerta?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Eliminar'),
        ),
      ],
    ),
  );
}
```

### 4. Loading States
```dart
_isLoading 
  ? Center(child: CircularProgressIndicator())
  : _alerts.isEmpty
    ? _buildEmptyState()
    : ListView.builder(...)
```

---

## Integración con Backend

### Autenticación
Todos los endpoints requieren token JWT:

```dart
// AlertsService lo maneja automáticamente:
final token = await AuthService.getToken();
headers: {
  if (token != null) 'Authorization': 'Bearer $token',
}
```

### Base URL
Configurado en `.env`:
```
API_BASE_URL=http://192.168.2.2:5000
```

### Endpoints Completos
- `GET /api/alerts/?type=todas`
- `GET /api/alerts/unread-count`
- `GET /api/alerts/critical-count?hours=24`
- `PUT /api/alerts/{id}/read`
- `PUT /api/alerts/read-all`
- `DELETE /api/alerts/{id}`
- `POST /api/alerts/reminder`

---

## Testing

### Crear Alerta de Prueba
```bash
# 1. Registrar glucosa crítica para generar alerta automática
curl -X POST http://192.168.2.2:5000/api/records/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "glucose_value": 200,
    "measurement_type": "ayunas"
  }'

# 2. Crear recordatorio manual
curl -X POST http://192.168.2.2:5000/api/alerts/reminder \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Medir glucosa",
    "message": "Es hora de tu medición"
  }'
```

### Verificar Alertas
```bash
curl -X GET http://192.168.2.2:5000/api/alerts/?type=todas \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Troubleshooting

### Error: "No token found"
**Problema:** Usuario no autenticado
**Solución:** Verificar que el usuario haya iniciado sesión

```dart
final token = await AuthService.getToken();
if (token == null) {
  Navigator.pushReplacementNamed(context, '/login');
}
```

### Error: "Connection refused"
**Problema:** Backend no accesible
**Solución:** Verificar IP en `.env` y que backend esté corriendo

```bash
# Verificar backend
curl http://192.168.2.2:5000/api/health
```

### Alertas no aparecen
**Problema:** No hay datos
**Solución:** Registrar glucosa fuera de rango normal

```dart
// Registrar glucosa > 180 para generar alerta
await RecordsService.createReading(
  glucoseValue: 200,
  measurementType: 'ayunas',
);
```

---

## Próximas Mejoras

- [ ] Push notifications (Firebase)
- [ ] Alertas programadas (recordatorios recurrentes)
- [ ] Configuración de umbrales personalizados
- [ ] Silenciar alertas temporalmente
- [ ] Categorías de alertas personalizadas
- [ ] Compartir alertas con médico

---

**Última actualización:** 2024-01-15
**Versión API:** v1.0
**Autor:** Sistema GlucPred
