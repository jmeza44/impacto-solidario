import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../views/activity_details_view.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListTile(
          leading: Icon(
            Icons.event,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            activity.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "${DateFormat('MMM dd, yyyy').format(activity.date)} - ${activity.location}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activity.category,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: _StatusBadge(status: activity.status),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ActivityDetailsView(activityId: activity.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ActivityStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case ActivityStatus.active:
        badgeColor = Colors.green;
        statusText = "Active";
        break;
      case ActivityStatus.completed:
        badgeColor = Colors.blue;
        statusText = "Completed";
        break;
      case ActivityStatus.canceled:
        badgeColor = Colors.red;
        statusText = "Canceled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
