import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/local_notification/easy/model/activitymodel.dart';

class ActivityCard extends StatelessWidget {
  final Activitymodel activity;
  const ActivityCard({super.key, required this.activity});

  // Icon theo type activity
  IconData get _icon {
    return switch (activity.type) {
      'education' => Icons.school_outlined,
      'recreational' => Icons.sports_outlined,
      'social' => Icons.people_outlined,
      'diy' => Icons.build_outlined,
      'charity' => Icons.volunteer_activism_outlined,
      'cooking' => Icons.restaurant_outlined,
      'relaxation' => Icons.spa_outlined,
      'music' => Icons.music_note_outlined,
      'busywork' => Icons.work_outline,
      _ => Icons.star_outline,
    };
  }

  Color get _color {
    return switch (activity.type) {
      'education' => Colors.blue,
      'recreational' => Colors.orange,
      'social' => Colors.purple,
      'cooking' => Colors.red,
      'relaxation' => Colors.teal,
      _ => Colors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(_icon, size: 48, color: _color),
          const SizedBox(height: 16),
          Text(
            'Daily Activity',
            style: TextStyle(
              fontSize: 13,
              color: _color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            activity.activity,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              activity.type.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                color: _color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
