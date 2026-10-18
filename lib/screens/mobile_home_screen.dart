import 'package:flutter/material.dart';

import 'mobile_dashboard_screen.dart';
import 'santri_screen.dart';
import 'locker_screen.dart';
import 'riwayat_screen.dart';
import '../services/notification_service.dart'; // <-- Pastikan import service notifikasi

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  int _selectedIndex = 0;

  static const Color navy = Color(0xFF0B1F3A);
  static const Color background = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    // Memaksa sistem Android untuk menampilkan pop-up izin notifikasi
    // saat halaman utama dimuat, sangat berguna untuk keperluan video demo sidang (N01)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.requestNotificationPermission();
    });
  }

  late final List<Widget> _pages = [
    const MobileDashboardScreen(),
    LockerScreen(),
    SantriScreen(),
    RiwayatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFE8EEF7),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            );
          }

          return const TextStyle(color: Colors.grey, fontSize: 11);
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: navy),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.door_sliding_outlined),
            selectedIcon: Icon(Icons.door_sliding, color: navy),
            label: 'Locker',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: navy),
            label: 'Santri',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded, color: navy),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
