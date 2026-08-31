import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/profile_provider.dart';
import '../../providers/trimester/trimester_provider.dart';
import '../../models/user_model.dart';
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
  bool _isSavingEdd = false;

  Future<void> _editExpectedDueDate(
      BuildContext context, ProfileProvider provider, String? currentEddStr) async {
    if (_isSavingEdd) return;

    DateTime initialDate;
    if (currentEddStr != null) {
      try {
        initialDate = DateTime.parse(currentEddStr);
      } catch (_) {
        initialDate = DateTime.now().add(const Duration(days: 90));
      }
    } else {
      initialDate = DateTime.now().add(const Duration(days: 90));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now().add(const Duration(days: 300)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.pink),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    final normalizedDate = DateTime(picked.year, picked.month, picked.day);

    setState(() => _isSavingEdd = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      await context.read<AuthService>().updateExpectedDueDate(normalizedDate);
      await provider.fetchUserData(user.uid);

      if (mounted) {
        await context.read<TrimesterProvider>().initialize();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expected Due Date updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update due date: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingEdd = false);
      }
    }
  }

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
    final authService = context.watch<AuthService>();
    final currentUser = authService.currentUser;

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
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(data?['name'] ?? "No name"),
                      subtitle: Text(formatText(data?['role'])),
                    ),
                    if (currentUser?.partnerDetails != null) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(currentUser!.partnerDetails!.name),
                        subtitle: Text(
                          '${formatText(currentUser.partnerDetails!.role.name)}\n${currentUser.partnerDetails!.email}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showPartnerDetailsSheet(
                                context,
                                provider,
                                currentUser.partnerDetails,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmRemovePartner(context, provider),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showPartnerDetailsSheet(
                              context,
                              provider,
                              null,
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text("Add Co-Parent / Partner"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.pink[300],
                              side: BorderSide(color: Colors.pink[200]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text("Gender"),
                        subtitle: Text(
                          formatText(provider.babyData?['gender']),
                        ),
                      ),
                      if (provider.babyData?['birthWeight'] != null) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.monitor_weight_outlined),
                          title: const Text("Birth Weight"),
                          subtitle: Text(
                            "${provider.babyData!['birthWeight']} kg",
                          ),
                        ),
                      ],
                      if (provider.babyData?['birthHeight'] != null) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.height),
                          title: const Text("Birth Height"),
                          subtitle: Text(
                            "${provider.babyData!['birthHeight']} cm",
                          ),
                        ),
                      ],
                      if (provider.babyData?['deliveryType'] != null) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.local_hospital_outlined),
                          title: const Text("Delivery Type"),
                          subtitle: Text(
                            formatText(provider.babyData!['deliveryType']),
                          ),
                        ),
                      ],
                      if (provider.babyData?['feedingType'] != null) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.flatware),
                          title: const Text("Feeding Preference"),
                          subtitle: Text(
                            formatText(provider.babyData!['feedingType']),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              PrimaryCard(
                child: Column(
                  children: [
                    if (stage == "pregnancy") ...[
                      ListTile(
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Expected Due Date'),
                        subtitle: Text(formatDate(data['pregnancy']?['edd'])),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _editExpectedDueDate(context, provider, data['pregnancy']?['edd']),
                      ),
                      const Divider(),
                    ],
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('This feature will be implemented soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.color_lens),
                      title: const Text('Theme'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('This feature will be implemented soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('This feature will be implemented soon'),
                          ),
                        );
                      },
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
                    ListTile(
                      leading:
                      const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                              'Are you sure you want to delete your account? '
                              'This action cannot be undone and all your health '
                              'records will be permanently erased.',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            if (user != null) {
                              context.read<AiInsightProvider>().clearUser(user.uid);
                            }
                            await context.read<AuthService>().deleteAccount();
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'requires-recent-login') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'For security reasons, please log out, '
                                    'log back in, and try again.',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to delete account: ${e.message}'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                              ),
                            );
                          }
                        }
                      },
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

  void _showPartnerDetailsSheet(
    BuildContext context,
    ProfileProvider provider,
    PartnerDetails? existingPartner,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existingPartner?.name ?? '');
    final emailController = TextEditingController(text: existingPartner?.email ?? '');
    ParentRole selectedRole = existingPartner?.role ?? ParentRole.partner;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existingPartner == null ? 'Add Co-Parent / Partner' : 'Edit Co-Parent / Partner',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an email';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ParentRole>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: ParentRole.values.map((role) {
                        String roleLabel;
                        switch (role) {
                          case ParentRole.mother:
                            roleLabel = 'Mother';
                            break;
                          case ParentRole.partner:
                            roleLabel = 'Partner / Dad';
                            break;
                          case ParentRole.caregiver:
                            roleLabel = 'Caregiver';
                            break;
                        }
                        return DropdownMenuItem<ParentRole>(
                          value: role,
                          child: Text(roleLabel),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => isSaving = true);
                                  try {
                                    final auth = context.read<AuthService>();
                                    await auth.savePartnerDetails(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      role: selectedRole,
                                    );
                                    if (auth.firebaseUser != null) {
                                      await provider.fetchUserData(auth.firebaseUser!.uid);
                                    }
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Co-Parent details saved successfully'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to save details: $e'),
                                        ),
                                      );
                                    }
                                  } finally {
                                    setModalState(() => isSaving = false);
                                  }
                                },
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmRemovePartner(BuildContext context, ProfileProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Co-Parent'),
          content: const Text('Remove co-parent details?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final auth = context.read<AuthService>();
                  await auth.removePartnerDetails();
                  if (auth.firebaseUser != null) {
                    await provider.fetchUserData(auth.firebaseUser!.uid);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Co-Parent details removed successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to remove details: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}