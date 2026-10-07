import 'package:flutter/material.dart';

import '../repositories/fingerprint_repository.dart';
import '../widgets/fingerprint_pending_card.dart';

class FingerprintPendingScreen extends StatelessWidget {
  FingerprintPendingScreen({super.key});

  final FingerprintRepository _repository = FingerprintRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fingerprint Baru')),
      body: StreamBuilder(
        stream: _repository.watchPendingFingerprints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Terjadi kesalahan:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final fingerprints = snapshot.data ?? [];

          if (fingerprints.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada fingerprint baru.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Fingerprint yang Belum Dilabeli',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 20),

              ...fingerprints.map(
                (fingerprint) =>
                    FingerprintPendingCard(fingerprint: fingerprint),
              ),
            ],
          );
        },
      ),
    );
  }
}
