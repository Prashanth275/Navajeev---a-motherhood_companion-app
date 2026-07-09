import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/profile_provider.dart';
import '../../providers/ai_insight_provider.dart';
import '../../widgets/app_widgets/primary_card.dart';
import '../../services/auth_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Future.microtask(() {
        context.read<ProfileProvider>().fetchUserData(user.uid);
      });
    }
  }

  String formatDate(dynamic date) {
    if (date == null) return "Not set";

    try {
      if (date.toString().contains('Timestamp')) {
        return DateFormat('dd MMM yyyy').format(date.toDate());
      }
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (e) {
      return "Invalid date";
    }
  }

  String formatText(String? value) {
    if (value == null || value.isEmpty) return "Not set";
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = provider.userData;

        if (data == null) {
          return const Center(child: Text("No data found"));
        }

        final stage = data['stage'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: data['photoUrl'] != null
                              ? NetworkImage(data['photoUrl'])
                              : null,
                          child: data['photoUrl'] == null
                              ? const Icon(Icons.person, size: 45)
                              : null,
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfilePage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.pinkAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      data['name'] ?? user?.email ?? "User",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      formatText(stage),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              PrimaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Parents",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    if (stage == "postpartum" &&
                        provider.parents.isNotEmpty)
                      ...provider.parents.map((parent) {
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(parent['name'] ?? "No name"),
                              subtitle: Text(
                                formatText(parent['role']),
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      }).toList()
                    else
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(data['name'] ?? "No name"),
                        subtitle: Text(formatText(data['role'])),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (stage == "pregnancy") ...[
                PrimaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pregnancy Info",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text("Due Date"),
                        subtitle: Text(
                          formatDate(data['pregnancy']?['edd']),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text("Notifications"),
                        subtitle: Text(
                          data['pregnancy']?['enable_notifications'] == true
                              ? "Enabled"
                              : "Disabled",
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (stage == "postpartum") ...[
                PrimaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Baby Info",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.child_care),
                        title: const Text("Baby Name"),
                        subtitle:
                        Text(provider.babyData?['name'] ?? "Not set"),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.cake),
                        title: const Text("Baby DOB"),
                        subtitle: Text(
                          formatDate(provider.babyData?['dob']),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text("Gender"),
                        subtitle: Text(
                          formatText(provider.babyData?['gender']),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              PrimaryCard(
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text('Notifications'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.color_lens),
                      title: Text('Theme'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Help & Support'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              PrimaryCard(
                child: Column(
                  children: [
                    ListTile(
                      leading:
                      const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () async {
                        if (user != null) {
                          context
                              .read<AiInsightProvider>()
                              .clearUser(user.uid);
                        }
                        await context.read<AuthService>().signOut();
                      },
                    ),
                    const Divider(),
                    const ListTile(
                      leading:
                      Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}