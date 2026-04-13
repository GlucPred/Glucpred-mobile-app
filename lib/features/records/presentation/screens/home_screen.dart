import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glucpred/core/config/theme.dart';
import 'package:glucpred/core/widgets/glucose_card.dart';
import 'package:glucpred/core/widgets/risk_card.dart';
import 'package:glucpred/core/widgets/trend_chart.dart';
import 'package:glucpred/features/records/presentation/viewmodels/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewModel? _homeVm;

  // UI-only state: text controllers and modal visibility
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  bool _showInputModal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeVm = context.read<HomeViewModel>();
      _homeVm!.loadData(isInitial: true);
      _homeVm!.startAutoUpdate();
    });
  }

  @override
  void dispose() {
    _homeVm?.stopAutoUpdate();
    _glucoseController.dispose();
    _insulinController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  void _openInputModal() => setState(() => _showInputModal = true);
  void _closeInputModal() => setState(() => _showInputModal = false);

  Future<void> _submitInitialData() async {
    final glucose = double.tryParse(_glucoseController.text);
    final insulin = double.tryParse(_insulinController.text);
    final carbs = double.tryParse(_carbsController.text);

    if (glucose == null || insulin == null || carbs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa valores válidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final vm = context.read<HomeViewModel>();
    final result = await vm.submitAnalysis(
      glucose: glucose,
      insulin: insulin,
      carbs: carbs,
    );

    if (!mounted) return;

    if (result != null) {
      _closeInputModal();
      _glucoseController.clear();
      _insulinController.clear();
      _carbsController.clear();

      _showPredictionResult(
        prediction: result['prediction'],
        alertLevel: result['alert_level'],
        recommendation: result['recommendation'],
        probabilities: result['probabilities'],
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al realizar predicción'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPredictionResult({
    required String prediction,
    required String alertLevel,
    required String recommendation,
    required Map<String, dynamic> probabilities,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color alertColor;
    IconData alertIcon;

    switch (alertLevel) {
      case 'Alto':
        alertColor = const Color(0xFFC72331);
        alertIcon = Icons.warning_amber_rounded;
        break;
      case 'Medio':
        alertColor = isDark ? AppTheme.warningColorBright : AppTheme.warningColor;
        alertIcon = Icons.info_outline;
        break;
      default:
        alertColor = const Color(0xFF337536);
        alertIcon = Icons.check_circle_outline;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(alertIcon, color: alertColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Predicción: $prediction',
                style: TextStyle(color: alertColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nivel de alerta: $alertLevel',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(recommendation),
            const SizedBox(height: 16),
            const Text(
              'Probabilidades:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...probabilities.entries.map((entry) {
              final percentage = (entry.value * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      '$percentage%',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Monitoreo de la glucosa')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.currentReading == null || vm.riskPrediction == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Monitoreo de la glucosa')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay datos disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => vm.loadData(isInitial: false),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _openInputModal,
              icon: const Icon(Icons.analytics),
              label: const Text('Analizar'),
              backgroundColor: const Color(0xFF0073E6),
            ),
            bottomSheet: _showInputModal ? _buildInputModal(context, vm) : null,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Monitoreo de la glucosa'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Color(0xFF0073E6)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compartir funcionalidad próximamente'),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.loadData(isInitial: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GlucoseCard(reading: vm.currentReading!),
                  const SizedBox(height: 16),
                  RiskCard(prediction: vm.riskPrediction!),
                  const SizedBox(height: 16),
                  TrendChart(data: vm.trendData),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          floatingActionButton: _showInputModal
              ? null
              : FloatingActionButton.extended(
                  onPressed: _openInputModal,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analizar'),
                  backgroundColor: const Color(0xFF0073E6),
                ),
          bottomSheet: _showInputModal ? _buildInputModal(context, vm) : null,
        );
      },
    );
  }

  Widget _buildInputModal(BuildContext context, HomeViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSubmitting = vm.isSubmitting;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232946) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Analizar datos de glucosa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _closeInputModal,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresa tus datos actuales para obtener una predicción',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _glucoseController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Glucosa actual (mg/dL)',
              hintText: 'Ej: 120',
              prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFF0073E6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1A1F3A) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _insulinController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Insulina últimos 30 min (unidades)',
              hintText: 'Ej: 5',
              prefixIcon: const Icon(Icons.medical_services, color: Color(0xFF0073E6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1A1F3A) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _carbsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Carbohidratos últimos 30 min (gramos)',
              hintText: 'Ej: 45',
              prefixIcon: const Icon(Icons.restaurant, color: Color(0xFF0073E6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1A1F3A) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0073E6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF0073E6), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los datos de Health Connect (frecuencia cardíaca, pasos, calorías) se leerán automáticamente',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0073E6)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0073E6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Analizar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
