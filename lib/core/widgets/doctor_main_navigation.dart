import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glucpred/features/alerts/presentation/viewmodels/alerts_view_model.dart';
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

class _DoctorMainNavigationState extends State<DoctorMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DoctorHomeScreen(),
    DoctorProfileScreen(),
    DoctorReportsScreen(),
    DoctorAlertsScreen(),
    DoctorSettingsScreen(),
  ];

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
