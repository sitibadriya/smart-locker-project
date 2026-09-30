import 'package:flutter/material.dart';
import '../models/santri.dart';
import '../repositories/santri_repository.dart';
import '../widgets/santri_card.dart';

class SantriProfileScreen extends StatelessWidget {
  const SantriProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = SantriRepository();

    return StreamBuilder<List<Santri>>(
      stream: repo.getSantriList(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final santriList = snapshot.data ?? [];

        if (santriList.isEmpty) {
          return const Center(
            child: Text('Data santri tidak ditemukan.\n(Menunggu data dari koleksi santri)'),
          );
        }

        return ListView.builder(
          itemCount: santriList.length,
          itemBuilder: (context, index) {
            return SantriCard(santri: santriList[index]);
          },
        );
      },
    );
  }
}