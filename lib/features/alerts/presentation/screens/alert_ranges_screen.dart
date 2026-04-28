import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glucpred/core/config/theme.dart';

class AlertRangesScreen extends StatefulWidget {
  const AlertRangesScreen({super.key});

  @override
  State<AlertRangesScreen> createState() => _AlertRangesScreenState();
}

class _AlertRangesScreenState extends State<AlertRangesScreen> {
  bool _autoAlertsEnabled = true;
  bool _loading = true;

  final _minValueController = TextEditingController();
  final _maxValueController = TextEditingController();
  final _precautionRangeController = TextEditingController();
  final _highCriticalController = TextEditingController();
  final _lowCriticalController = TextEditingController();
  final _trendDurationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRanges();
  }

  Future<void> _loadRanges() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _minValueController.text =
          prefs.getString('range_min') ?? '70';
      _maxValueController.text =
          prefs.getString('range_max') ?? '140';
      _precautionRangeController.text =
          prefs.getString('range_precaution') ?? '100-140';
      _highCriticalController.text =
          prefs.getString('range_high_critical') ?? '180';
      _lowCriticalController.text =
          prefs.getString('range_low_critical') ?? '60';
      _trendDurationController.text =
          prefs.getString('range_trend_duration') ?? '12h';
      _autoAlertsEnabled = prefs.getBool('auto_alerts_enabled') ?? true;
      _loading = false;
    });
  }

  Future<void> _saveRanges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('range_min', _minValueController.text.trim());
    await prefs.setString('range_max', _maxValueController.text.trim());
    await prefs.setString('range_precaution', _precautionRangeController.text.trim());
    await prefs.setString('range_high_critical', _highCriticalController.text.trim());
    await prefs.setString('range_low_critical', _lowCriticalController.text.trim());
    await prefs.setString('range_trend_duration', _trendDurationController.text.trim());
    await prefs.setBool('auto_alerts_enabled', _autoAlertsEnabled);
  }

  @override
  void dispose() {
    _minValueController.dispose();
    _maxValueController.dispose();
    _precautionRangeController.dispose();
    _highCriticalController.dispose();
    _lowCriticalController.dispose();
    _trendDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF9FAFB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF0073E6),
          ),
        ),
        title: const Text('Rangos de alerta'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descripción
              const Text(
                'Define los valores mínimos y máximos de glucosa para las alertas clínicas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C7C93),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Card con todos los campos
              Card(
                elevation: 0,
                color: isDark ? AppTheme.darkCardColor : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE0E6EB), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEditableField(
                        label: 'Valor mínimo (mg/dL)',
                        description: 'Límite inferior para hipoglucemia.',
                        controller: _minValueController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Valor máximo (mg/dL)',
                        description: 'Límite superior para hiperglucemia.',
                        controller: _maxValueController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Rango de precaución (mg/dL)',
                        description: 'Zona intermedia donde el paciente debe estar atento.',
                        controller: _precautionRangeController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Notificar si supera nivel crítico (mg/dL)',
                        description: 'Nivel crítico que genera alerta roja.',
                        controller: _highCriticalController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Notificar si baja nivel crítico (mg/dL)',
                        description: 'Nivel crítico que genera alerta azul.',
                        controller: _lowCriticalController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Duración promedio de tendencia (horas)',
                        description: 'Intervalo que usa la app para evaluar tendencias.',
                        controller: _trendDurationController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),
                      
                      // Switch de alertas automáticas
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activar alertas automáticas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Permite activar o desactivar notificaciones clínicas automáticas.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6C7C93),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Switch(
                                value: _autoAlertsEnabled,
                                onChanged: (value) {
                                  setState(() => _autoAlertsEnabled = value);
                                },
                                activeThumbColor: const Color(0xFF0073E6),
                                activeTrackColor: const Color(0xFF0073E6).withAlpha(80),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    await _saveRanges();
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Cambios guardados correctamente'),
                        backgroundColor: Color(0xFF337536),
                      ),
                    );
                    navigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0073E6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String description,
    required TextEditingController controller,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE0E6EB), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE0E6EB), width: 1),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF0073E6),
                    size: 20,
                  ),
                  onPressed: () {
                    // Foco en el campo para editar
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
