import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_widgets/primary_card.dart';
import '../../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
   const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text(
            'User & Baby Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          PrimaryCard(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.help),
                  title: Text('Help & Support'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await context.read<AuthService>().signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
