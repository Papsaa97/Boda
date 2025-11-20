// lib/features/activity/presentation/screens/activity_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';


import '../controllers/activity_controller.dart';
import 'activity_add_screen.dart';


class ActivityListScreen extends ConsumerWidget {
  const ActivityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sledujeme stav ActivityControlleru (AsyncValue<List<ActivityEntity>>).:contentReference[oaicite:4]{index=4}
    final activitiesAsync = ref.watch(activityControllerProvider);

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zahradník Bóďa - Timeline'),
      ),
      body: activitiesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Chyba při načítání aktivit: $error'),
        ),
data: (activities) {
  return CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BodasTipCard(),
        ),
      ),
      if (activities.isEmpty)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text('Zatím žádné aktivity'),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final activity = activities[index];

              return ListTile(
                leading: (activity.imagePath != null &&
                        activity.imagePath!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(activity.imagePath!),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.local_florist),
                title: Text(activity.title),
                subtitle: Text(
                  dateFormat.format(activity.date),
                ),
              );
            },
            childCount: activities.length,
          ),
        ),
    ],
  );
},

          ),
          floatingActionButton: FloatingActionButton(
          onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ActivityAddScreen(),
            ),
          );
          },
            child: const Icon(Icons.add),
        ),
    );
  }
  
}
class BodasTipCard extends StatelessWidget {
  const BodasTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tip od Bódi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'I plevel roste, když se nedíváš!',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

