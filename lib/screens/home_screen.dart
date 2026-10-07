import 'package:flutter/material.dart';

import 'fingerprint_pending_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Locker')),
      body: Center(
        child: SizedBox(
          width: 350,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FingerprintPendingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.fingerprint),
            label: const Text(
              'Fingerprint Baru',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
