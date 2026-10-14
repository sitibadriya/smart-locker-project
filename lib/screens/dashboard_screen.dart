import 'package:flutter/material.dart';

import '../models/santri.dart';
import '../repositories/fingerprint_repository.dart';
import 'fingerprint_screen.dart';
import 'locker_screen.dart';
import 'santri_screen.dart';
import 'system_status_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color primary = Color(0xFF0B1F3A); // Navy
  static const Color green = Color(0xFF2E7D32); // Akses berhasil
  static const Color red = Color(0xFFC62828); // Akses gagal
  static const Color orange = Color(0xFFF59E0B); // Peringatan
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color background = Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    final repository = FingerprintRepository();

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: StreamBuilder<List<Santri>>(
          stream: repository.watchSantriAktif(),
          builder: (context, santriSnapshot) {
            final jumlahSantri = santriSnapshot.data?.length ?? 0;

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: repository.watchAllFingerprintMapping(),
              builder: (context, fingerprintSnapshot) {
                final jumlahFingerprint = fingerprintSnapshot.data?.length ?? 0;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(
                        context,
                        jumlahSantri,
                        jumlahFingerprint,
                      ),
                    ),

                    // Empat statistik aktivitas locker.
                    SliverToBoxAdapter(
                      child: SmartLockerStatistics(repository: repository),
                    ),

                    // Ringkasan sistem.
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Sistem',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStat(
                                    icon: Icons.people_alt_rounded,
                                    title: 'Santri Aktif',
                                    value: '$jumlahSantri',
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStat(
                                    icon: Icons.fingerprint_rounded,
                                    title: 'Fingerprint',
                                    value: '$jumlahFingerprint',
                                    color: green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSystemStatus(context),
                          ],
                        ),
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

  Widget _buildStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: textGrey)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int jumlahSantri,
    int jumlahFingerprint,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMART LOCKER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Sistem Keamanan dan Monitoring Locker',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pantau dan kelola sistem locker santri.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeaderMiniInfo(
                  icon: Icons.people_alt_rounded,
                  label: 'Santri Aktif',
                  value: '$jumlahSantri',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeaderMiniInfo(
                  icon: Icons.fingerprint_rounded,
                  label: 'Fingerprint Aktif',
                  value: '$jumlahFingerprint',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderMenuButton(
                icon: Icons.people_alt_rounded,
                label: 'Data Santri',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SantriScreen()),
                ),
              ),
              _HeaderMenuButton(
                icon: Icons.lock_outline_rounded,
                label: 'Data Locker',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LockerScreen()),
                ),
              ),
              _HeaderMenuButton(
                icon: Icons.fingerprint_rounded,
                label: 'Fingerprint',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FingerprintScreen()),
                ),
              ),
              _HeaderMenuButton(
                icon: Icons.monitor_heart_outlined,
                label: 'Status Sistem',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SystemStatusScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monitor_heart_outlined,
                color: primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Status Sistem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SystemStatusScreen(),
                    ),
                  );
                },
                child: const Text('Detail'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _SystemStatusRow(
            icon: Icons.cloud_done_rounded,
            label: 'Firebase',
            status: 'Terhubung jika konfigurasi aktif',
            color: green,
          ),
          const SizedBox(height: 12),
          const _SystemStatusRow(
            icon: Icons.memory_rounded,
            label: 'ESP32',
            status: 'Periksa halaman Status Sistem',
            color: orange,
          ),
          const SizedBox(height: 12),
          const _SystemStatusRow(
            icon: Icons.fingerprint_rounded,
            label: 'Sensor Fingerprint',
            status: 'Periksa halaman Status Sistem',
            color: orange,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// STATISTIK AKTIVITAS LOCKER
// ==========================================

class SmartLockerStatistics extends StatefulWidget {
  final FingerprintRepository repository;

  const SmartLockerStatistics({super.key, required this.repository});

  @override
  State<SmartLockerStatistics> createState() => _SmartLockerStatisticsState();
}

class _SmartLockerStatisticsState extends State<SmartLockerStatistics> {
  DateTime _tanggalDipilih = DateTime.now();

  double? _rataRataJeda;
  int _jumlahAktivitas = 0;
  double? _persentaseBerhasil;
  double? _persentaseGagal;

  bool _sedangMemuat = true;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    _muatStatistik();
  }

  Future<void> _muatStatistik() async {
    setState(() {
      _sedangMemuat = true;
      _pesanError = null;
    });

    try {
      final hasil = await Future.wait<dynamic>([
        widget.repository.hitungRataRataJeda10Aktivitas(),
        widget.repository.hitungJumlahAktivitasTanggal(_tanggalDipilih),
        widget.repository.hitungPersentaseBerhasil(_tanggalDipilih),
        widget.repository.hitungPersentaseGagal(_tanggalDipilih),
      ]);

      if (!mounted) return;

      setState(() {
        _rataRataJeda = hasil[0] as double?;
        _jumlahAktivitas = hasil[1] as int;
        _persentaseBerhasil = hasil[2] as double?;
        _persentaseGagal = hasil[3] as double?;
        _sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sedangMemuat = false;
        _pesanError = 'Gagal memuat statistik.';
      });
    }
  }

  Future<void> _pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih tanggal aktivitas',
    );

    if (tanggal == null || !mounted) return;

    setState(() {
      _tanggalDipilih = tanggal;
    });

    await _muatStatistik();
  }

  String _formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    return '$hari/$bulan/${tanggal.year}';
  }

  String _formatMenit(double? nilai) {
    if (nilai == null) return '-';
    if (nilai < 1) return '${(nilai * 60).round()} detik';
    return '${nilai.toStringAsFixed(1)} menit';
  }

  String _formatPersentase(double? nilai) {
    if (nilai == null) return '-';
    return '${nilai.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Aktivitas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DashboardScreen.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ringkasan aktivitas akses locker.',
            style: TextStyle(fontSize: 12, color: DashboardScreen.textGrey),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _pilihTanggal,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: DashboardScreen.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tanggal: ${_formatTanggal(_tanggalDipilih)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: DashboardScreen.textDark,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_sedangMemuat)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_pesanError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _pesanError!,
                style: const TextStyle(color: DashboardScreen.red),
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer_outlined,
                        title: 'Rata-rata Jeda',
                        value: _formatMenit(_rataRataJeda),
                        subtitle: '10 aktivitas terbaru',
                        color: DashboardScreen.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.event_note_rounded,
                        title: 'Total Aktivitas',
                        value: '$_jumlahAktivitas',
                        subtitle: 'Pada tanggal dipilih',
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Akses Berhasil',
                        value: _formatPersentase(_persentaseBerhasil),
                        subtitle: 'Diizinkan',
                        color: DashboardScreen.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.cancel_outlined,
                        title: 'Akses Gagal',
                        value: _formatPersentase(_persentaseGagal),
                        subtitle: 'Ditolak',
                        color: DashboardScreen.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (!_sedangMemuat && _pesanError == null)
            const Text(
              'Persentase dihitung dari seluruh aktivitas pada tanggal yang dipilih.',
              style: TextStyle(fontSize: 11, color: DashboardScreen.textGrey),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// KARTU STATISTIK
// ==========================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: DashboardScreen.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DashboardScreen.textDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: DashboardScreen.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// INFORMASI MINI DI HEADER
// ==========================================

class _HeaderMiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderMiniInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TOMBOL MENU HEADER
// ==========================================

class _HeaderMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderMenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// BARIS STATUS SISTEM
// ==========================================

class _SystemStatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color color;

  const _SystemStatusRow({
    required this.icon,
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DashboardScreen.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 11,
                  color: DashboardScreen.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
