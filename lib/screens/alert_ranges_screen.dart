import 'package:flutter/material.dart';

class AlertRangesScreen extends StatefulWidget {
  const AlertRangesScreen({super.key});

  @override
  State<AlertRangesScreen> createState() => _AlertRangesScreenState();
}

class _AlertRangesScreenState extends State<AlertRangesScreen> {
  bool _autoAlertsEnabled = true;
  
  // Controladores para los campos de texto
  final _minValueController = TextEditingController(text: '70');
  final _maxValueController = TextEditingController(text: '140');
  final _precautionRangeController = TextEditingController(text: '100-140');
  final _highCriticalController = TextEditingController(text: '180');
  final _lowCriticalController = TextEditingController(text: '60');
  final _trendDurationController = TextEditingController(text: '12h');

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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE0E6EB), width: 1),
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
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Valor máximo (mg/dL)',
                        description: 'Límite superior para hiperglucemia.',
                        controller: _maxValueController,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Rango de precaución (mg/dL)',
                        description: 'Zona intermedia donde el paciente debe estar atento.',
                        controller: _precautionRangeController,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Notificar si supera nivel crítico (mg/dL)',
                        description: 'Nivel crítico que genera alerta roja.',
                        controller: _highCriticalController,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Notificar si baja nivel crítico (mg/dL)',
                        description: 'Nivel crítico que genera alerta azul.',
                        controller: _lowCriticalController,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEditableField(
                        label: 'Duración promedio de tendencia (horas)',
                        description: 'Intervalo que usa la app para evaluar tendencias.',
                        controller: _trendDurationController,
                      ),
                      const SizedBox(height: 24),
                      
                      // Switch de alertas automáticas
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Activar alertas automáticas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000),
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
                                  setState(() {
                                    _autoAlertsEnabled = value;
                                  });
                                },
                                activeColor: const Color(0xFF0073E6),
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cambios guardados correctamente'),
                        backgroundColor: Color(0xFF337536),
                      ),
                    );
                    Navigator.pop(context);
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6C7C93),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E6EB), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF000000),
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
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFE0E6EB), width: 1),
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
