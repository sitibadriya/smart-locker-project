import 'package:flutter/material.dart';

import '../models/fingerprint_pending.dart';
import '../models/santri.dart';
import '../repositories/fingerprint_repository.dart';

class FingerprintLabelScreen extends StatefulWidget {
  final FingerprintPending fingerprint;

  const FingerprintLabelScreen({super.key, required this.fingerprint});

  @override
  State<FingerprintLabelScreen> createState() => _FingerprintLabelScreenState();
}

class _FingerprintLabelScreenState extends State<FingerprintLabelScreen> {
  final FingerprintRepository _repository = FingerprintRepository();

  String? selectedIdSantri;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final fingerprint = widget.fingerprint;

    return Scaffold(
      appBar: AppBar(title: const Text('Labeli Fingerprint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Labeli Fingerprint',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            _buildInfo('ID Fingerprint', fingerprint.idFingerprint),

            _buildInfo('ID Sensor', fingerprint.idSensor.toString()),

            _buildInfo('Jari', fingerprint.jari),

            _buildInfo('Urutan', fingerprint.urutanJari.toString()),

            _buildInfo('Perangkat', fingerprint.idPerangkat),

            _buildInfo('Locker', fingerprint.idLocker),

            const SizedBox(height: 24),

            const Text(
              'Pilih Santri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            StreamBuilder<List<Santri>>(
              stream: _repository.watchSantriAktif(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text(
                    'Gagal mengambil data santri:\n'
                    '${snapshot.error}',
                  );
                }

                final daftarSantri = snapshot.data ?? [];

                if (daftarSantri.isEmpty) {
                  return const Text('Belum ada data santri aktif.');
                }

                return DropdownButtonFormField<String>(
                  value: selectedIdSantri,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Pilih santri',
                  ),
                  items: daftarSantri.map((santri) {
                    return DropdownMenuItem<String>(
                      value: santri.idSantri,
                      child: Text(
                        '${santri.idSantri} - '
                        '${santri.nama}',
                      ),
                    );
                  }).toList(),
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            selectedIdSantri = value;
                          });
                        },
                );
              },
            ),

            const SizedBox(height: 24),

            if (selectedIdSantri != null)
              FutureBuilder<Santri?>(
                future: _ambilSantriTerpilih(selectedIdSantri!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final santri = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfo('ID Santri', santri.idSantri),

                      _buildInfo('Nama', santri.nama),

                      _buildInfo('Locker Santri', santri.lockerId),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue.withOpacity(0.08),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Fingerprint ini akan '
                                'dihubungkan dengan santri '
                                'yang dipilih.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedIdSantri == null || isSaving
                    ? null
                    : _simpanMapping,
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Simpan Mapping',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // AMBIL DATA SANTRI TERPILIH
  // ==========================================

  Future<Santri?> _ambilSantriTerpilih(String idSantri) async {
    final daftarSantri = await _repository.watchSantriAktif().first;

    for (final santri in daftarSantri) {
      if (santri.idSantri == idSantri) {
        return santri;
      }
    }

    return null;
  }

  // ==========================================
  // SIMPAN MAPPING
  // ==========================================

  Future<void> _simpanMapping() async {
    final fingerprint = widget.fingerprint;

    if (selectedIdSantri == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final santri = await _ambilSantriTerpilih(selectedIdSantri!);

      if (santri == null) {
        throw Exception('Data santri tidak ditemukan.');
      }

      await _repository.simpanMapping(
        pendingDocumentId: fingerprint.documentId,
        idSensor: fingerprint.idSensor,
        idFingerprint: fingerprint.idFingerprint,
        idSantri: santri.idSantri,
        namaSantri: santri.nama,
        idLocker: santri.lockerId,
        idPerangkat: fingerprint.idPerangkat,
        jari: fingerprint.jari,
        urutanJari: fingerprint.urutanJari,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fingerprint berhasil dimapping.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan mapping:\n$e')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ==========================================
  // INFORMASI
  // ==========================================

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
