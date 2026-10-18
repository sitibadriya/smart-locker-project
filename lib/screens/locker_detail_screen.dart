import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LockerDetailScreen extends StatefulWidget {
  final String idLocker;
  final String idPerangkat;

  const LockerDetailScreen({
    super.key,
    required this.idLocker,
    required this.idPerangkat,
  });

  @override
  State<LockerDetailScreen> createState() => _LockerDetailScreenState();
}

class _LockerDetailScreenState extends State<LockerDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isProcessing = false;

  static const Color navy = Color(0xFF0B1F3A);
  static const Color navyLight = Color(0xFF163E6D);
  static const Color background = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color green = Color(0xFF2E7D32);

  Future<void> _handleRemoteUnlock() async {
    setState(() => _isProcessing = true);
    try {
      await _firestore.collection('locker-config').doc(widget.idLocker).update({
        'remoteCommand': 'UNLOCK',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perintah Buka Loker berhasil dikirim!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim perintah: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleResetLocker() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Reset / Ganti Pemilik'),
        content: Text(
          'Apakah Anda yakin ingin mengosongkan Loker ${widget.idLocker}? '
          'Template sidik jari di sensor fisik akan dihapus dan kepemilikan santri akan dilepas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reset Pemilik',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isProcessing = true);
      try {
        await _firestore
            .collection('locker-config')
            .doc(widget.idLocker)
            .update({
              'resetCommand': 'RESET_OWNER',
              'updatedAt': FieldValue.serverTimestamp(),
            });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perintah Reset dikirim ke ESP32...')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal melakukan reset: $e')));
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Locker ${widget.idLocker}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('locker-config')
            .doc(widget.idLocker)
            .snapshots(),
        builder: (context, snapshot) {
          final data = (snapshot.hasData && snapshot.data!.exists)
              ? snapshot.data!.data() as Map<String, dynamic>? ?? {}
              : {};

          final String activeSantriId = data['activeSantriId'] ?? '';
          final bool isOccupied = activeSantriId.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
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
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.idLocker,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.idPerangkat,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Status Perangkat',
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: green,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perangkat Aktif',
                            style: TextStyle(
                              color: textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ESP32 terdaftar pada sistem.',
                            style: TextStyle(color: textGrey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Informasi Locker',
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'ID Locker',
                      value: widget.idLocker,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.memory_outlined,
                      label: 'ID Perangkat',
                      value: widget.idPerangkat,
                    ),
                    const Divider(height: 24),
                    const _DetailRow(
                      icon: Icons.fingerprint,
                      label: 'Sensor',
                      value: 'JM-101B',
                    ),
                    const Divider(height: 24),
                    const _DetailRow(
                      icon: Icons.lock_outline,
                      label: 'Pengunci',
                      value: 'Solenoid 12V',
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (isOccupied ? Colors.green : Colors.orange)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isOccupied ? Icons.person : Icons.person_off,
                            color: isOccupied ? Colors.green : Colors.orange,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Pemilik',
                                style: TextStyle(color: textGrey, fontSize: 12),
                              ),
                              const SizedBox(height: 3),
                              isOccupied
                                  ? FutureBuilder<DocumentSnapshot>(
                                      future: _firestore
                                          .collection('santri')
                                          .doc(activeSantriId)
                                          .get(),
                                      builder: (context, santriSnap) {
                                        String namaSantri = activeSantriId;
                                        if (santriSnap.hasData &&
                                            santriSnap.data!.exists) {
                                          final sData =
                                              santriSnap.data!.data()
                                                  as Map<String, dynamic>?;
                                          namaSantri =
                                              sData?['nama'] ?? activeSantriId;
                                        }
                                        return Text(
                                          'Terisi: $namaSantri',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    )
                                  : const Text(
                                      'Kosong / Belum Ada Pemilik',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock_open, color: Colors.white),
                  label: const Text(
                    'Buka Loker (Remote Unlock)',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _handleRemoteUnlock,
                ),
                const SizedBox(height: 12),
                if (isOccupied)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_remove, color: Colors.red),
                    label: const Text(
                      'Reset / Ganti Pemilik',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleResetLocker,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
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
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: teal, size: 21),
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
                  fontSize: 14,
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
