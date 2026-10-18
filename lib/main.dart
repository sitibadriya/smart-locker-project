import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'services/notification_service.dart';
import 'screens/locker_screen.dart';
import 'screens/mobile_home_screen.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase dengan aman
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Gagal menginisialisasi Firebase: $e");
  }

  // Inisialisasi Notifikasi & Permintaan Izin Otomatis (Skenario N01)
  // Dibungkus try-catch agar tidak membuat aplikasi freeze jika gagal/ditolak di web/mobile
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint("Gagal menginisialisasi NotificationService: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Locker IoT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Menyesuaikan tampilan halaman utama berdasarkan platform (Web / Mobile)
      home: kIsWeb ? const HomeScreen() : const MobileHomeScreen(),
    );
  }
}
