import 'package:flutter/material.dart';
import '../services/glucose_service.dart';
import '../widgets/glucose_card.dart';
import '../widgets/risk_card.dart';
import '../widgets/trend_chart.dart';
import '../models/glucose_reading.dart';
import '../models/risk_prediction.dart';
import '../models/trend_point.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GlucoseReading currentReading;
  late RiskPrediction riskPrediction;
  late List<TrendPoint> trendData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      currentReading = GlucoseService.getCurrentReading();
      riskPrediction = GlucoseService.getRiskPrediction();
      trendData = GlucoseService.getTrendData();
    });
  }

  void _refreshData() {
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos actualizados'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        onRefresh: () async {
          _refreshData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GlucoseCard(reading: currentReading),
              const SizedBox(height: 16),
              RiskCard(prediction: riskPrediction),
              const SizedBox(height: 16),
              TrendChart(data: trendData),
              const SizedBox(height: 80), // Espacio para el bottom nav
            ],
          ),
        ),
      ),
    );
  }
}
