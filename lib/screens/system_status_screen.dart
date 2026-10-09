import 'package:flutter/material.dart';

class SystemStatusScreen extends StatelessWidget {
  const SystemStatusScreen({super.key});

  static const Color navy = Color(0xFF0B1F3A);
  static const Color background = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color green = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          'Status Sistem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: green.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: green,
                    size: 52,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Sistem Aktif',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Smart Locker siap digunakan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textGrey, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _StatusItem(
            icon: Icons.wifi_rounded,
            title: 'Koneksi',
            value: 'Terhubung',
          ),

          _StatusItem(
            icon: Icons.cloud_done_rounded,
            title: 'Firebase',
            value: 'Terhubung',
          ),

          _StatusItem(
            icon: Icons.fingerprint_rounded,
            title: 'Fingerprint',
            value: 'Siap digunakan',
          ),

          _StatusItem(
            icon: Icons.lock_rounded,
            title: 'Smart Locker',
            value: 'Aktif',
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatusItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  static const Color navy = Color(0xFF0B1F3A);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color green = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: navy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: navy),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),

          const Icon(Icons.check_circle, color: green, size: 19),

          const SizedBox(width: 6),

          Text(value, style: const TextStyle(color: textGrey, fontSize: 12)),
        ],
      ),
    );
  }
}
