import 'package:flutter/material.dart';
import '../models/locker_activity.dart';
import '../repositories/locker_repository.dart';
import '../widgets/locker_activity_card.dart';

class LockerActivityScreen extends StatelessWidget {
  const LockerActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = LockerRepository();

    return StreamBuilder<List<LockerActivity>>(
      stream: repo.getLockerActivities(),
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

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          return const Center(
            child: Text('Belum ada aktivitas loker.\n(Menunggu data dari locker-activity)'),
          );
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            return LockerActivityCard(activity: activities[index]);
          },
        );
      },
    );
  }
}