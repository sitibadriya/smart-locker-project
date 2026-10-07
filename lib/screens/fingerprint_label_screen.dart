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

            _buildInfo('ID Sensor', fingerprint.idSensor.toString()),

            _buildInfo('Perangkat', fingerprint.idPerangkat),

            _buildInfo('Locker', fingerprint.idLocker),

            const SizedBox(height: 24),

            const Text(
              'Pilih Santri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // ======================================
            // DROPDOWN SANTRI
            // ======================================
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

                final idMasihAda = daftarSantri.any(
                  (santri) => santri.idSantri == selectedIdSantri,
                );

                final nilaiDropdown = idMasihAda ? selectedIdSantri : null;

                return DropdownButtonFormField<String>(
                  value: nilaiDropdown,
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

            // ======================================
            // DATA SANTRI + FINGERPRINT
            // ======================================
            if (selectedIdSantri != null)
              StreamBuilder<List<Santri>>(
                stream: _repository.watchSantriAktif(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final daftarSantri = snapshot.data!;

                  Santri? santriTerpilih;

                  for (final santri in daftarSantri) {
                    if (santri.idSantri == selectedIdSantri) {
                      santriTerpilih = santri;
                      break;
                    }
                  }

                  if (santriTerpilih == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DATA SANTRI
                      _buildInfo('ID Santri', santriTerpilih.idSantri),

                      _buildInfo('Nama', santriTerpilih.nama),

                      _buildInfo('Locker Santri', santriTerpilih.lockerId),

                      const SizedBox(height: 16),

                      // FINGERPRINT
                      _buildFingerprintSection(santriTerpilih.idSantri),
                    ],
                  );
                },
              ),

            const SizedBox(height: 32),

            // ======================================
            // TOMBOL SIMPAN
            // ======================================
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
  // BAGIAN FINGERPRINT
  // ==========================================

  Widget _buildFingerprintSection(String idSantri) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _repository.watchFingerprintSantri(idSantri),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text(
            'Gagal mengambil data fingerprint:\n'
            '${snapshot.error}',
          );
        }

        final fingerprintList = snapshot.data ?? [];

        final jumlah = fingerprintList.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fingerprint',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '$jumlah dari 5 fingerprint '
              'terdaftar',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            // ==================================
            // 5 SLOT FINGERPRINT
            // ==================================
            for (int i = 0; i < 5; i++)
              _buildFingerprintSlot(
                nomorSlot: i + 1,
                fingerprintList: fingerprintList,
              ),

            // ==================================
            // PESAN JIKA SUDAH 5
            // ==================================
            if (jumlah >= 5)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange.withOpacity(0.15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Maksimal 5 fingerprint '
                        'sudah tercapai.',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // ==========================================
  // SATU SLOT FINGERPRINT
  // ==========================================

  Widget _buildFingerprintSlot({
    required int nomorSlot,
    required List<Map<String, dynamic>> fingerprintList,
  }) {
    Map<String, dynamic>? fingerprint;

    if (nomorSlot <= fingerprintList.length) {
      fingerprint = fingerprintList[nomorSlot - 1];
    }

    final sudahTerdaftar = fingerprint != null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: sudahTerdaftar ? Colors.green : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            sudahTerdaftar ? Icons.check_circle : Icons.radio_button_unchecked,
            color: sudahTerdaftar ? Colors.green : Colors.grey,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: sudahTerdaftar
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fingerprint!['idFingerprint'] ?? 'Fingerprint',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID Sensor: '
                        '${fingerprint['idSensor']}',
                      ),
                    ],
                  )
                : Text(
                    'Slot $nomorSlot — '
                    'Belum digunakan',
                    style: const TextStyle(color: Colors.grey),
                  ),
          ),
        ],
      ),
    );
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
      final daftarSantri = await _repository.watchSantriAktif().first;

      Santri? santriTerpilih;

      for (final santri in daftarSantri) {
        if (santri.idSantri == selectedIdSantri) {
          santriTerpilih = santri;
          break;
        }
      }

      if (santriTerpilih == null) {
        throw Exception('Data santri tidak ditemukan.');
      }

      await _repository.simpanMapping(
        pendingDocumentId: fingerprint.documentId,
        idSensor: fingerprint.idSensor,
        idSantri: santriTerpilih.idSantri,
        namaSantri: santriTerpilih.nama,
        idLocker: santriTerpilih.lockerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fingerprint berhasil dilabeli.')),
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
