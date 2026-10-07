import 'package:flutter/material.dart';

import '../models/fingerprint_pending.dart';
import '../screens/fingerprint_label_screen.dart';

class FingerprintPendingCard extends StatelessWidget {
  final FingerprintPending fingerprint;

  const FingerprintPendingCard({super.key, required this.fingerprint});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fingerprint Baru',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              'ID Sensor : ${fingerprint.idSensor}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text(
              'Locker : ${fingerprint.idLocker}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text(
              'Perangkat : ${fingerprint.idPerangkat}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text(
              'Status : ${fingerprint.status}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FingerprintLabelScreen(fingerprint: fingerprint),
                    ),
                  );
                },
                child: const Text('Labeli Fingerprint'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
