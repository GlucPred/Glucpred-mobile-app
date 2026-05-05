import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glucpred/features/alerts/presentation/viewmodels/alerts_view_model.dart';
import 'package:glucpred/features/records/presentation/screens/home_screen.dart';
import 'package:glucpred/features/profile/presentation/screens/profile_screen.dart';
import 'package:glucpred/features/records/presentation/screens/charts_screen.dart';
import 'package:glucpred/features/alerts/presentation/screens/notifications_screen.dart';
import 'package:glucpred/features/settings/presentation/screens/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final _chartsKey = GlobalKey<ChartsScreenState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileScreen(),
    ChartsScreen(key: _chartsKey),
    const NotificationsScreen(),
    const SettingsScreen(),
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
          // Reload charts data whenever the user switches to that tab
          if (index == 2 && _currentIndex != 2) {
            _chartsKey.currentState?.reload();
          }
          // Clear unread badge when user opens Alerts tab
          if (index == 3) {
            context.read<AlertsViewModel>().clearUnreadCount();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0073E6),
        unselectedItemColor: const Color(0xFF6C7C93),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
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
