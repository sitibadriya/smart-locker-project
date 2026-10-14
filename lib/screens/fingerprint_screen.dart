import 'package:flutter/material.dart';

import '../repositories/fingerprint_repository.dart';

class FingerprintScreen extends StatelessWidget {
  FingerprintScreen({super.key});

  final FingerprintRepository _repository = FingerprintRepository();

  static const Color navy = Color(0xFF0B1F3A);
  static const Color background = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          'Data Fingerprint',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repository.watchAllFingerprintMapping(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: navy));
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
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: fingerprints.length,
            itemBuilder: (context, index) {
              final fingerprint = fingerprints[index];

              return _FingerprintCard(fingerprint: fingerprint);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: navy.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 42,
                color: navy,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Belum Ada Fingerprint',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Belum terdapat fingerprint yang terdaftar pada sistem.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textGrey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _FingerprintCard extends StatelessWidget {
  final Map<String, dynamic> fingerprint;

  const _FingerprintCard({required this.fingerprint});

  static const Color navy = Color(0xFF0B1F3A);
  static const Color background = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color green = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final idFingerprint = fingerprint['idFingerprint']?.toString() ?? '-';

    final idSensor = fingerprint['idSensor']?.toString() ?? '-';

    final idSantri = fingerprint['idSantri']?.toString() ?? '-';

    final namaSantri = fingerprint['namaSantri']?.toString() ?? '-';

    final idLocker = fingerprint['idLocker']?.toString() ?? '-';

    final statusAktif = fingerprint['statusAktif'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: navy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: navy,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idFingerprint,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'ID Sensor: $idSensor',
                      style: const TextStyle(fontSize: 12, color: textGrey),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusAktif
                      ? Colors.green.withOpacity(0.10)
                      : Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusAktif ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                    color: statusAktif ? green : Colors.red.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Santri',
                  value: namaSantri,
                ),

                const SizedBox(height: 10),

                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'ID Santri',
                  value: idSantri,
                ),

                const SizedBox(height: 10),

                _InfoRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Locker',
                  value: idLocker,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: textGrey),

        const SizedBox(width: 10),

        Text(label, style: const TextStyle(fontSize: 12, color: textGrey)),

        const Spacer(),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
        ),
      ],
    );
  }
}
