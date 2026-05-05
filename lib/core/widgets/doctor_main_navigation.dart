import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glucpred/core/services/fcm_service.dart';
import 'package:glucpred/features/alerts/presentation/viewmodels/alerts_view_model.dart';
import 'package:glucpred/features/doctor/presentation/viewmodels/doctor_home_view_model.dart';
import 'package:glucpred/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:glucpred/features/doctor/presentation/screens/doctor_profile_screen.dart';
import 'package:glucpred/features/doctor/presentation/screens/doctor_reports_screen.dart';
import 'package:glucpred/features/doctor/presentation/screens/doctor_alerts_screen.dart';
import 'package:glucpred/features/doctor/presentation/screens/doctor_settings_screen.dart';
import 'package:glucpred/core/config/theme.dart';

class DoctorMainNavigation extends StatefulWidget {
  const DoctorMainNavigation({super.key});

  @override
  State<DoctorMainNavigation> createState() => _DoctorMainNavigationState();
}

class _DoctorMainNavigationState extends State<DoctorMainNavigation>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DoctorHomeScreen(),
    DoctorProfileScreen(),
    DoctorReportsScreen(),
    DoctorAlertsScreen(),
    DoctorSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Navigate to Alerts tab when a FCM notification is tapped.
    FcmService.onAlertTapped = _goToAlertsTab;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// App resumed from background/terminated — refresh critical doctor screens.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshOnResume();
    }
  }

  void _goToAlertsTab() {
    if (mounted) setState(() => _currentIndex = 3);
  }

  void _refreshOnResume() {
    context.read<AlertsViewModel>().loadAlerts();
    context.read<DoctorHomeViewModel>().loadDoctorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            context.read<AlertsViewModel>().clearUnreadCount();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Gráfica',
          ),
          BottomNavigationBarItem(
            icon: Consumer<AlertsViewModel>(
              builder: (_, vm, __) {
                final count = vm.unreadCount;
                if (count == 0) return const Icon(Icons.notifications);
                return Badge.count(
                  count: count > 99 ? 99 : count,
                  child: const Icon(Icons.notifications),
                );
              },
            ),
            label: 'Alertas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
