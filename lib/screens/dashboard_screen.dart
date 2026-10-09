import 'package:flutter/material.dart';

import '../models/fingerprint_pending.dart';
import '../models/santri.dart';
import '../repositories/fingerprint_repository.dart';
import 'fingerprint_label_screen.dart';
import 'fingerprint_pending_screen.dart';
import 'fingerprint_screen.dart';
import 'locker_screen.dart';
import 'santri_screen.dart';
import 'system_status_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ======================================================
  // WARNA TEMA
  // ======================================================

  static const Color navy = Color(0xFF0B1F3A);
  static const Color navyLight = Color(0xFF163E6D);
  static const Color background = Color(0xFFF4F7FB);
  static const Color teal = Color(0xFF00897B);
  static const Color green = Color(0xFF2E7D32);
  static const Color textDark = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);

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

            return StreamBuilder<List<FingerprintPending>>(
              stream: repository.watchPendingFingerprints(),
              builder: (context, pendingSnapshot) {
                final pending = pendingSnapshot.data ?? [];

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: repository.watchAllFingerprintMapping(),
                  builder: (context, mappingSnapshot) {
                    final mapping = mappingSnapshot.data ?? [];

                    return CustomScrollView(
                      slivers: [
                        // ==================================================
                        // HEADER
                        // ==================================================

                        SliverToBoxAdapter(
                          child: _buildHeader(
                            context,
                            santri.length,
                            pending.length,
                          ),
                        ),

                        // ==================================================
                        // RINGKASAN SISTEM
                        // ==================================================
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ringkasan Sistem',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // ==============================
                                // BARIS 1
                                // ==============================
                                Row(
                                  children: [
                                    // SANTRI
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SantriScreen(),
                                            ),
                                          );
                                        },
                                        child: _StatCard(
                                          icon: Icons.people_alt_rounded,
                                          title: 'Santri',
                                          value: santri.length.toString(),
                                          iconColor: navy,
                                          backgroundColor: const Color(
                                            0xFFE8EEF7,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // FINGERPRINT
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  FingerprintScreen(),
                                            ),
                                          );
                                        },
                                        child: _StatCard(
                                          icon: Icons.fingerprint_rounded,
                                          title: 'Fingerprint',
                                          value: mapping.length.toString(),
                                          iconColor: teal,
                                          backgroundColor: const Color(
                                            0xFFE5F4F1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // ==============================
                                // BARIS 2
                                // ==============================
                                Row(
                                  children: [
                                    // LOCKER
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LockerScreen(),
                                            ),
                                          );
                                        },
                                        child: _StatCard(
                                          icon: Icons.lock_rounded,
                                          title: 'Locker',
                                          value: santri.length.toString(),
                                          iconColor: navyLight,
                                          backgroundColor: const Color(
                                            0xFFE9EFF8,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // PENDING
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  FingerprintPendingScreen(),
                                            ),
                                          );
                                        },
                                        child: _StatCard(
                                          icon: Icons.pending_actions_rounded,
                                          title: 'Pending',
                                          value: pending.length.toString(),
                                          iconColor: Colors.orange,
                                          backgroundColor: const Color(
                                            0xFFFFF3E0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ==================================================
                        // STATUS SISTEM
                        // ==================================================
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SystemStatusScreen(),
                                  ),
                                );
                              },
                              child: _buildSystemStatus(),
                            ),
                          ),
                        ),

                        // ==================================================
                        // FINGERPRINT PENDING HEADER
                        // ==================================================
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Fingerprint Pending',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: pending.isEmpty
                                        ? Colors.green.withOpacity(0.10)
                                        : Colors.orange.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${pending.length} data',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: pending.isEmpty
                                          ? green
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ==================================================
                        // PENDING CONTENT
                        // ==================================================
                        if (pending.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                              child: _buildEmptyPending(),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final fingerprint = pending[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildPendingCard(
                                    context,
                                    fingerprint,
                                  ),
                                );
                              }, childCount: pending.length),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ======================================================
  // HEADER
  // ======================================================

  Widget _buildHeader(
    BuildContext context,
    int jumlahSantri,
    int jumlahPending,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [navy, navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==============================
          // ICON + STATUS ONLINE
          // ==============================

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 9, color: Color(0xFF66BB6A)),
                    SizedBox(width: 7),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ==============================
          // GREETING
          // ==============================
          const Text(
            'Selamat Datang 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Kelola dan pantau Smart Locker dengan mudah.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.80),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          // ==============================
          // MINI INFO
          // ==============================
          Row(
            children: [
              Expanded(
                child: _HeaderMiniInfo(
                  icon: Icons.people_alt_rounded,
                  value: jumlahSantri.toString(),
                  label: 'Santri Aktif',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _HeaderMiniInfo(
                  icon: Icons.pending_actions_rounded,
                  value: jumlahPending.toString(),
                  label: 'Menunggu',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================================================
  // STATUS SISTEM
  // ======================================================

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: green,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistem Aktif',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Smart Locker siap digunakan.',
                  style: TextStyle(fontSize: 13, color: textGrey),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  // ======================================================
  // EMPTY PENDING
  // ======================================================

  Widget _buildEmptyPending() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: green, size: 34),
          ),

          const SizedBox(height: 14),

          const Text(
            'Tidak Ada Data Pending',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Tidak ada fingerprint yang menunggu proses pelabelan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // PENDING CARD
  // ======================================================

  Widget _buildPendingCard(
    BuildContext context,
    FingerprintPending fingerprint,
  ) {
    return Container(
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
                      'ID Sensor ${fingerprint.idSensor}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      fingerprint.idPerangkat,
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
                  color: Colors.orange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: textGrey,
                ),

                const SizedBox(width: 10),

                const Text(
                  'Locker',
                  style: TextStyle(color: textGrey, fontSize: 13),
                ),

                const Spacer(),

                Text(
                  fingerprint.idLocker,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FingerprintLabelScreen(fingerprint: fingerprint),
                  ),
                );
              },
              icon: const Icon(Icons.edit_rounded, size: 19),
              label: const Text(
                'Beri Label Fingerprint',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// STAT CARD
// ======================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final Color backgroundColor;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),

          const SizedBox(height: 14),

          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: DashboardScreen.textDark,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: DashboardScreen.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// HEADER MINI INFO
// ======================================================

class _HeaderMiniInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeaderMiniInfo({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.85), size: 20),

          const SizedBox(width: 9),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
