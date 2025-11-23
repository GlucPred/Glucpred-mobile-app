# GlucPred - Aplicación Móvil de Monitoreo de Glucosa

Aplicación móvil Flutter para el monitoreo de niveles de glucosa con predicción de riesgo y análisis de tendencias.

## 🎨 Características

### Pantalla Principal (Home)
- **Glucosa actual**: Muestra el nivel actual de glucosa con estado visual (normal, alto, bajo)
- **Predicción de riesgo**: Alerta sobre posibles riesgos en las próximas horas
- **Gráfico de tendencias**: Visualización de las últimas 12 horas de datos
- **Pull to refresh**: Actualiza los datos deslizando hacia abajo

### Perfil
- Información personal del usuario
- Datos médicos relevantes (tipo de diabetes, HbA1c, etc.)
- Opción de editar perfil

### Estadísticas
- Promedio de glucosa de los últimos 7 días
- Porcentaje de lecturas en rango objetivo
- Historial de lecturas recientes con estados visuales

### Notificaciones
- Alertas de niveles fuera de rango
- Recordatorios de medición
- Notificaciones de tendencias detectadas
- Recordatorios de medicación

### Configuración
- Activar/desactivar notificaciones
- Configurar unidades de medida (mg/dl o mmol/L)
- Definir rangos objetivo personalizados
- Modo oscuro (próximamente)
- Opciones de privacidad y ayuda

## 🚀 Cómo ejecutar

### Prerrequisitos
- Flutter SDK (3.0 o superior)
- Dart SDK
- Emulador o dispositivo físico

### Ejecutar en modo desarrollo

**Windows:**
```bash
flutter run -d windows
```

**Android:**
```bash
flutter run -d android
```

### Ejecutar en modo release

```bash
flutter run --release
```

## 🧪 Ejecutar tests

```bash
flutter test
```

## 📦 Dependencias

Las dependencias se manejan en `pubspec.yaml`. Actualmente, la app usa:
- Flutter SDK
- Material Design 3

Para instalar dependencias:
```bash
flutter pub get
```