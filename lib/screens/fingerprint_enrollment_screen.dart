import 'package:flutter/material.dart';

import '../models/santri.dart';
import '../repositories/fingerprint_repository.dart';

class FingerprintEnrollmentScreen extends StatefulWidget {
  final Santri santri;

  const FingerprintEnrollmentScreen({super.key, required this.santri});

  @override
  State<FingerprintEnrollmentScreen> createState() =>
      _FingerprintEnrollmentScreenState();
}

class _FingerprintEnrollmentScreenState
    extends State<FingerprintEnrollmentScreen> {
  final FingerprintRepository _repository = FingerprintRepository();

  bool _isLoading = false;

  static const Color navy = Color(0xFF0B1F3A);
  static const Color navyLight = Color(0xFF163E6D);
  static const Color background = Color(0xFFF4F7FB);
  static const Color teal = Color(0xFF00897B);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);

  // ============================================================
  // MAPPING LOCKER → PERANGKAT ESP32
  // ============================================================
  String _getIdPerangkat(String idLocker) {
    switch (idLocker) {
      case 'L01':
        return 'esp32-locker-01';

      case 'L02':
        return 'esp32-locker-02';

      default:
        throw Exception('Perangkat untuk locker $idLocker belum terdaftar.');
    }
  }

  // ============================================================
  // MULAI PENDAFTARAN FINGERPRINT
  // ============================================================
  Future<void> _mulaiPendaftaran() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Tentukan ESP32 berdasarkan locker santri
      final idPerangkat = _getIdPerangkat(widget.santri.lockerId);

      // Kirim perintah START_ENROLL ke Firestore
      await _repository.mulaiEnrollment(
        idSantri: widget.santri.idSantri,
        namaSantri: widget.santri.nama,
        idLocker: widget.santri.lockerId,
        idPerangkat: idPerangkat,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perintah pendaftaran dikirim ke $idPerangkat.'),
          backgroundColor: teal,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memulai pendaftaran:\n$e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daftarkan Finger',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [navy, navyLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Pendaftaran Fingerprint',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daftarkan sidik jari untuk mengamankan '
                      'locker santri.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // DATA SANTRI
              // ==================================================
              const Text(
                'Data Santri',
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.person,
                      label: 'Nama Santri',
                      value: widget.santri.nama,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'ID Santri',
                      value: widget.santri.idSantri,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Locker',
                      value: widget.santri.lockerId,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.memory_outlined,
                      label: 'Perangkat',
                      value: _getIdPerangkat(widget.santri.lockerId),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // INFORMASI PROSES
              // ==================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F3),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: teal.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Setelah pendaftaran dimulai, ESP32 pada '
                        'locker yang dipilih akan mengaktifkan '
                        'mode pendaftaran fingerprint. Santri '
                        'kemudian diminta menempelkan jari pada '
                        'sensor fingerprint di locker.',
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // TOMBOL
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _mulaiPendaftaran,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text(
                    _isLoading
                        ? 'Mengirim Perintah...'
                        : 'Mulai Daftarkan Finger',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // CATATAN
              // ==================================================
              Center(
                child: Text(
                  'Fingerprint akan disimpan pada sensor '
                  'locker.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textGrey, fontSize: 13),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// WIDGET INFORMASI
// ================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color teal = Color(0xFF00897B);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: teal, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: textGrey, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
