import 'package:flutter/material.dart';

class FingerprintLabelScreen extends StatelessWidget {
  const FingerprintLabelScreen({super.key});

  static const Color navy = Color(0xFF0B1F3A);
  static const Color background = Color(0xFFF4F7FB);
  static const Color teal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Pengelolaan Fingerprint'),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint, size: 72, color: teal),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pendaftaran Fingerprint',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pendaftaran sidik jari dilakukan melalui '
                'menu Fingerprint dengan memilih santri '
                'yang akan didaftarkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: navy.withValues(alpha: 0.10)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: teal),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Pilih santri yang akan didaftarkan.'),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: teal),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tekan Daftarkan Finger untuk '
                            'memulai proses enrollment.',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: teal),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hasil pendaftaran akan dipetakan '
                            'langsung ke data santri tanpa '
                            'halaman pending.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Kembali',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
