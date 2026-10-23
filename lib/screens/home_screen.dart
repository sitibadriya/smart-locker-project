import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'riwayat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [DashboardScreen(), RiwayatScreen()];

  static const Color navy = Color(0xFF0B1F3A);
  static const Color background = Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          height: 72,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFFE8EEF7),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: navy,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
            }

            return const TextStyle(color: Colors.grey, fontSize: 12);
          }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.dashboard_rounded, color: navy),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.history_rounded, color: navy),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }
}
