import 'package:flutter/material.dart';
import 'package:navajeev_m/screens/tracker/trimester_tracker/trimester_tracker_screen.dart';
import 'package:navajeev_m/screens/tracker/vaccination_tracker_page.dart';
import 'package:navajeev_m/screens/tracker/baby_growth_tracker/growth_home_page.dart';

class TrackersPage extends StatelessWidget {
  final String? singleTracker;

  const TrackersPage({super.key, this.singleTracker});

  @override
  Widget build(BuildContext context) {
    if (singleTracker != null) {
      if (singleTracker == 'Vaccination Tracker') {
        return const VaccinationTrackerPage();
      }
      if (singleTracker == 'Growth Tracker') {
        return const GrowthHomePage();
      }

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForTracker(singleTracker!),
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                singleTracker!,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Tracker implementation coming soon...'),
            ],
          ),
        ),
      );
    }

    final trackers = [
      {'title': 'Vaccination Tracker', 'icon': Icons.vaccines},
      {'title': 'Growth Tracker', 'icon': Icons.show_chart},
      {'title': 'Sleep Tracker', 'icon': Icons.bedtime},
      {'title': 'Feed Tracker', 'icon': Icons.restaurant_menu},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trackers.length,
      itemBuilder: (context, index) {
        final item = trackers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(item['icon'] as IconData, size: 40),
            title: Text(item['title'] as String),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (item['title'] == 'Vaccination Tracker') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VaccinationTrackerPage(),
                  ),
                );
              }
              else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TrackersPage(singleTracker: item['title'] as String),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  IconData _getIconForTracker(String title) {
    switch (title) {
      case 'Growth Tracker':
        return Icons.show_chart;
      case 'Sleep Tracker':
        return Icons.bedtime;
      case 'Feed Tracker':
        return Icons.restaurant_menu;
      default:
        return Icons.track_changes;
    }
  }
}

