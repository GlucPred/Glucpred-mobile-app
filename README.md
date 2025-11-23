# GlucPred - Aplicación Móvil de Monitoreo de Glucosa

Aplicación móvil Flutter para el monitoreo de niveles de glucosa con predicción de riesgo y análisis de tendencias.

## 📁 Estructura del Proyecto

```
lib/
├── config/
│   └── theme.dart              # Configuración del tema de la app
├── models/
│   ├── glucose_reading.dart    # Modelo de lectura de glucosa
│   ├── risk_prediction.dart    # Modelo de predicción de riesgo
│   └── trend_point.dart        # Modelo de punto de tendencia
├── screens/
│   ├── home_screen.dart        # Pantalla principal con monitoreo
│   ├── profile_screen.dart     # Perfil del usuario
│   ├── stats_screen.dart       # Estadísticas e historial
│   ├── notifications_screen.dart # Notificaciones y alertas
│   └── settings_screen.dart    # Configuración de la app
├── services/
│   └── glucose_service.dart    # Servicio de datos de glucosa
├── widgets/
│   ├── glucose_card.dart       # Widget de tarjeta de glucosa actual
│   ├── risk_card.dart          # Widget de predicción de riesgo
│   ├── trend_chart.dart        # Widget de gráfico de tendencias
│   └── main_navigation.dart    # Navegación principal con bottom nav
└── main.dart                   # Punto de entrada de la aplicación
```

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

**iOS:**
```bash
flutter run -d ios
```

**Web:**
```bash
flutter run -d chrome
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

## 🏗️ Arquitectura

La aplicación sigue una arquitectura limpia con separación de responsabilidades:

- **Models**: Clases de datos simples (POJO/PODO)
- **Services**: Lógica de negocio y generación de datos mock
- **Widgets**: Componentes reutilizables de UI
- **Screens**: Pantallas completas de la aplicación
- **Config**: Configuraciones globales (tema, constantes)

## 📊 Datos Mock

Actualmente, la aplicación utiliza datos generados aleatoriamente por `GlucoseService` para demostración. En una implementación real, estos servicios se conectarían a:
- APIs backend
- Bases de datos locales (SQLite)
- Dispositivos de medición de glucosa vía Bluetooth
- Servicios de sincronización en la nube

## 🎯 Próximas Características

- [ ] Integración con dispositivos de medición
- [ ] Sincronización con backend
- [ ] Modo oscuro completo
- [ ] Exportar datos en PDF
- [ ] Integración con Apple Health / Google Fit
- [ ] Predicción de glucosa con ML
- [ ] Recordatorios inteligentes
- [ ] Comparación con otros períodos

## 👨‍💻 Desarrollo

Para agregar nuevas funcionalidades:

1. **Modelos**: Agrega nuevas clases en `lib/models/`
2. **Servicios**: Implementa lógica en `lib/services/`
3. **Widgets**: Crea componentes reutilizables en `lib/widgets/`
4. **Pantallas**: Añade nuevas pantallas en `lib/screens/`

## 📝 Notas

- Los datos actuales son ficticios para propósitos de demostración
- La navegación usa `IndexedStack` para mantener el estado de las pantallas
- El tema sigue Material Design 3 con colores personalizados
- Todas las pantallas son responsive y adaptables

## 📄 Licencia

Este proyecto es parte de una tesis académica.

---

**Desarrollado con ❤️ usando Flutter**
