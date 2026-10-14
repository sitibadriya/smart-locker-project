import 'package:flutter/material.dart';

import '../models/santri.dart';
import '../repositories/fingerprint_repository.dart';
import 'fingerprint_screen.dart';
import 'system_status_screen.dart';

class MobileDashboardScreen extends StatelessWidget {
  const MobileDashboardScreen({super.key});

  static const Color navy = Color(0xFF0B1F3A);
  static const Color background = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color teal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    final repository = FingerprintRepository();

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: StreamBuilder<List<Santri>>(
          stream: repository.watchSantriAktif(),
          builder: (context, santriSnapshot) {
            final santri = santriSnapshot.data ?? [];

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: repository.watchAllFingerprintMapping(),
              builder: (context, fingerprintSnapshot) {
                final fingerprints = fingerprintSnapshot.data ?? [];

                final isLoading =
                    santriSnapshot.connectionState == ConnectionState.waiting ||
                    fingerprintSnapshot.connectionState ==
                        ConnectionState.waiting;

                if (santriSnapshot.hasError || fingerprintSnapshot.hasError) {
                  return _buildError();
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(santri.length)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const Text(
                            'Ringkasan Sistem',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.all(30),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    title: 'Santri Aktif',
                                    value: '${santri.length}',
                                    icon: Icons.people_alt_outlined,
                                    color: const Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    title: 'Fingerprint',
                                    value: '${fingerprints.length}',
                                    icon: Icons.fingerprint,
                                    color: teal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                Expanded(
                                  child: _StatCard(
                                    title: 'Locker',
                                    value: '2',
                                    icon: Icons.door_sliding_outlined,
                                    color: Color(0xFF7B1FA2),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    title: 'Maks. per Santri',
                                    value: '5',
                                    icon: Icons.verified_user_outlined,
                                    color: Color(0xFFEF6C00),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 28),
                          const Text(
                            'Akses Cepat',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 14),

                          _QuickAction(
                            icon: Icons.fingerprint,
                            title: 'Kelola Fingerprint',
                            subtitle: 'Lihat data sidik jari terdaftar',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FingerprintScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _QuickAction(
                            icon: Icons.monitor_heart_outlined,
                            title: 'Status Sistem',
                            subtitle: 'Lihat informasi sistem Smart Locker',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SystemStatusScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline, color: navy, size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Informasi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Satu santri dapat memiliki maksimal '
                                        'lima sidik jari aktif sesuai urutan '
                                        'pendaftaran yang ditentukan.',
                                        style: TextStyle(
                                          color: textGrey,
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int jumlahSantri) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [navy, Color(0xFF163E6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'SMART LOCKER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Selamat Datang 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pantau dan kelola Smart Locker dengan mudah.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_alt_outlined, color: Colors.white),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Total santri aktif',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                Text(
                  '$jumlahSantri',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 44, color: Colors.redAccent),
            SizedBox(height: 12),
            Text(
              'Data gagal dimuat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            SizedBox(height: 6),
            Text(
              'Periksa koneksi dan konfigurasi Firebase.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF7),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: MobileDashboardScreen.navy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
            ],
          ),
        ),
      ),
    );
  }
}
