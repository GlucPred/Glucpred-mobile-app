## 📱 RecordsService - Guía de Uso en Flutter

Este servicio conecta la app con los endpoints de registros de glucosa del backend.

---

## 🎯 Métodos Disponibles

### 1. **Obtener Última Medición** (Para pantalla INICIO)

```dart
import '../services/records_service.dart';

// En tu HomeScreen o widget de inicio
Future<void> _loadLatestReading() async {
  final result = await RecordsService.getLatestReading();
  
  if (result['success']) {
    final record = result['record'];
    
    setState(() {
      // Actualizar UI con los datos
      glucoseValue = record['glucose_value']; // ej: 103.0
      classification = record['classification']; // ej: "normal"
      measurementTime = DateTime.parse(record['measurement_time']);
    });
    
    // Ejemplo de uso en widget:
    // Text('${glucoseValue.toStringAsFixed(0)} mg/dL')
    // Icon basado en classification
  } else {
    // Mostrar mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
  }
}
```

**Clasificaciones posibles:**
- `"bajo"` → < 70 mg/dL (Hipoglucemia) ⚠️ Rojo
- `"normal"` → 70-140 mg/dL ✅ Verde
- `"alto"` → 140-180 mg/dL ⚠️ Amarillo
- `"critico"` → > 180 mg/dL 🚨 Rojo crítico

---

### 2. **Crear Nueva Medición** (Desde CGM o input manual)

```dart
// Ejemplo: Usuario ingresa manualmente o se recibe del CGM
Future<void> _createNewReading(double value) async {
  final result = await RecordsService.createReading(
    glucoseValue: value,
    measurementTime: DateTime.now(), // Opcional, default: ahora
  );
  
  if (result['success']) {
    final record = result['record'];
    
    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Medición registrada: ${record['glucose_value']} mg/dL'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Recargar datos
    _loadLatestReading();
  } else {
    // Error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
    );
  }
}

// Uso en botón flotante:
FloatingActionButton(
  onPressed: () async {
    // Mostrar diálogo para ingresar valor
    final value = await _showInputDialog();
    if (value != null) {
      await _createNewReading(value);
    }
  },
  child: Icon(Icons.add),
)
```

---

### 3. **Estadísticas Rápidas** (Tarjetas en INICIO)

```dart
// Para mostrar tarjetas de resumen en pantalla de inicio
Future<void> _loadDailyStats() async {
  final result = await RecordsService.getStatistics(hours: 24); // Últimas 24h
  
  if (result['success']) {
    final stats = result['statistics'];
    
    setState(() {
      // Estadísticas disponibles:
      totalReadings = stats['total_readings']; // ej: 8
      average = stats['average']; // ej: 126.5
      minValue = stats['min']; // ej: 88.0
      maxValue = stats['max']; // ej: 167.0
      
      // Clasificaciones (para calcular porcentajes)
      final classifications = stats['classifications'];
      normalCount = classifications['normal']; // ej: 5
      highCount = classifications['alto']; // ej: 2
      criticalCount = classifications['critico']; // ej: 1
      lowCount = classifications['bajo']; // ej: 0
      
      // Última lectura (igual a getLatestReading)
      final lastReading = stats['last_reading'];
    });
  }
}

// Ejemplo de tarjetas en UI:
Card(
  child: Column(
    children: [
      Text('Promedio Hoy'),
      Text('${average.toStringAsFixed(0)} mg/dL'),
    ],
  ),
)

// Calcular % en rango:
final percentage = RecordsService.calculateNormalPercentage(
  stats['classifications'], 
  stats['total_readings']
);
Text('${percentage.toStringAsFixed(0)}% en rango');
```

**Períodos disponibles:**
- `hours: 24` → Hoy
- `hours: 168` → 7 días (semana)
- `hours: 720` → 30 días (mes)

---

### 4. **Tendencia para Gráficos** (Pantalla ESTADÍSTICAS)

```dart
// Para gráfico de línea en pestaña de estadísticas
Future<void> _loadTrendData(int hours) async {
  setState(() => isLoading = true);
  
  final result = await RecordsService.getTrend(hours: hours);
  
  if (result['success']) {
    final records = result['records'] as List;
    
    setState(() {
      // Convertir a TrendPoint (tu modelo existente)
      trendData = records.map((r) => TrendPoint(
        timestamp: DateTime.parse(r['measurement_time']),
        value: r['glucose_value'].toDouble(),
        classification: r['classification'],
      )).toList();
      
      isLoading = false;
    });
  } else {
    setState(() => isLoading = false);
    // Mostrar error
  }
}

// Tabs para diferentes períodos:
TabBar(
  tabs: [
    Tab(text: 'Hoy'),
    Tab(text: 'Semana'),
    Tab(text: 'Mes'),
  ],
)

// Al cambiar de tab:
void _onTabChanged(int index) {
  final hours = [24, 168, 720][index]; // Hoy, Semana, Mes
  _loadTrendData(hours);
}
```

---

### 5. **Historial Paginado** (Tabla de registros)

```dart
class HistoryScreen extends StatefulWidget {
  // ...
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> records = [];
  int currentPage = 0;
  int pageSize = 50;
  bool hasMore = true;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    if (isLoading || !hasMore) return;
    
    setState(() => isLoading = true);
    
    final result = await RecordsService.getHistory(
      limit: pageSize,
      offset: currentPage * pageSize,
      // Opcional: filtrar por fechas
      // startDate: DateTime(2025, 11, 1),
      // endDate: DateTime(2025, 11, 30),
    );
    
    if (result['success']) {
      setState(() {
        records.addAll(result['records']);
        hasMore = result['has_more'];
        currentPage++;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      // Mostrar error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Cargar más al llegar al final
        if (index == records.length) {
          _loadHistory();
          return Center(child: CircularProgressIndicator());
        }
        
        final record = records[index];
        return ListTile(
          leading: Icon(
            Icons.water_drop,
            color: _getColorByClassification(record['classification']),
          ),
          title: Text('${record['glucose_value']} mg/dL'),
          subtitle: Text(
            DateTime.parse(record['measurement_time']).toString(),
          ),
          trailing: Chip(
            label: Text(record['classification']),
          ),
        );
      },
    );
  }
}
```

---

## 🎨 Helpers de UI

### Obtener color según clasificación

```dart
Color _getColorByClassification(String classification) {
  final colorName = RecordsService.getColorByClassification(classification);
  
  switch (colorName) {
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
```

### Obtener mensaje descriptivo

```dart
String message = RecordsService.getMessageByClassification('normal');
// Retorna: "Nivel normal"
```

---

## 🔄 Ejemplo Completo: HomeScreen con API Real

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  double? _currentGlucose;
  String? _classification;
  DateTime? _lastMeasurement;
  Map<String, dynamic>? _dailyStats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Cargar última medición
    final latestResult = await RecordsService.getLatestReading();
    
    // Cargar estadísticas del día
    final statsResult = await RecordsService.getStatistics(hours: 24);

    if (latestResult['success'] && statsResult['success']) {
      setState(() {
        final record = latestResult['record'];
        _currentGlucose = record['glucose_value'].toDouble();
        _classification = record['classification'];
        _lastMeasurement = DateTime.parse(record['measurement_time']);
        
        _dailyStats = statsResult['statistics'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      // Mostrar error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Tarjeta principal de glucosa actual
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Glucosa Actual'),
                    Text(
                      '${_currentGlucose?.toStringAsFixed(0)} mg/dL',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      RecordsService.getMessageByClassification(_classification ?? ''),
                      style: TextStyle(
                        color: _getColorByClassification(_classification ?? ''),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Estadísticas del día
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        Text('Promedio Hoy'),
                        Text('${_dailyStats?['average']?.toStringAsFixed(0) ?? '--'} mg/dL'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        Text('Lecturas'),
                        Text('${_dailyStats?['total_readings'] ?? 0}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📌 Notas Importantes

1. **Autenticación**: Todos los métodos requieren token JWT (manejado automáticamente por `AuthService.getToken()`)

2. **Manejo de errores**: Siempre verificar `result['success']` antes de usar los datos

3. **Formato de fechas**: El backend usa ISO 8601 (`2025-11-16T20:00:00`), usar `DateTime.parse()` y `toIso8601String()`

4. **Clasificaciones**: 
   - Backend: `"bajo"`, `"normal"`, `"alto"`, `"critico"`
   - UI: Mapear a colores/iconos apropiados

5. **Rangos de glucosa** (mg/dL):
   - Bajo: < 70
   - Normal: 70-140
   - Alto: 140-180
   - Crítico: > 180

6. **Períodos comunes**:
   - Hoy: 24 horas
   - Semana: 168 horas (7 × 24)
   - Mes: 720 horas (30 × 24)
