import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/vaccine_providers.dart';
import '../../services/auth_service.dart';
import '../../widgets/vaccine_card.dart';
import '../../theme/app_colors.dart';
import '../../models/vaccine_model.dart';

class VaccinationTrackerPage extends StatefulWidget {
  const VaccinationTrackerPage({super.key});

  @override
  State<VaccinationTrackerPage> createState() =>
      _VaccinationTrackerPageState();
}

class _VaccinationTrackerPageState
    extends State<VaccinationTrackerPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final user = authService.currentUser;
    if (user?.babyDetails != null) {
      final provider =
      Provider.of<VaccineProvider>(context, listen: false);

      provider.initializeWithDob(
        user!.babyDetails!.dateOfBirth,
      );

      _initialized = true;
    }
  }

  Future<void> _markAsDone(String id) async {
    final provider =
    Provider.of<VaccineProvider>(context, listen: false);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:
      provider.dob ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      await provider.markAsDone(id, pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Consumer<VaccineProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final dob = provider.dob;

          if (dob == null) {
            return const Center(child: Text('Baby DOB not available'));
          }

          final upcomingVaccines = provider.vaccines
              .where((v) => v.getStatus(dob) != VaccineStatus.done)
              .toList()
            ..sort(
                  (a, b) => a
                  .getDueDate(dob)
                  .compareTo(b.getDueDate(dob)),
            );

          final completedVaccines = provider.vaccines
              .where((v) => v.getStatus(dob) == VaccineStatus.done)
              .toList();


          Vaccine? nextDue;
          List<Vaccine> remainingUpcoming = [];

          if (upcomingVaccines.isNotEmpty) {
            nextDue = upcomingVaccines.first;
            if (upcomingVaccines.length > 1) {
              remainingUpcoming = upcomingVaccines.sublist(1);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProgressBar(provider),
              const SizedBox(height: 24),

              // Next Due (Featured)
              if (nextDue != null) ...[
                VaccineCard(
                  vaccine: nextDue,
                  babyDob: provider.dob!,
                  onMarkAsDone: () => _markAsDone(nextDue!.id),
                  style: VaccineCardStyle.featured,
                ),

                const SizedBox(height: 16),
              ],

              // Upcoming
              if (remainingUpcoming.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Upcoming Vaccines",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...remainingUpcoming.map(
                      (v) => VaccineCard(
                    vaccine: v,
                    babyDob: provider.dob!,
                    onMarkAsDone: () => _markAsDone(v.id),
                    style: VaccineCardStyle.list,
                  ),
                ),
              ],

              // Completed
              if (completedVaccines.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Completed Vaccines ✓",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...completedVaccines.map(
                      (v) => VaccineCard(
                    vaccine: v,
                    babyDob: provider.dob!,
                    onMarkAsDone: () {},
                    style: VaccineCardStyle.completed,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(VaccineProvider provider) {
    final total = provider.totalCount;
    final completed = provider.completedCount;
    final percent =
    total == 0 ? 0 : ((completed / total) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vaccination Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed of $total vaccines completed',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completed / total,
                    backgroundColor: const Color(0xFFF0F0F0),
                    color:
                    AppColors.success.withValues(alpha: 0.7),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$percent% completed',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
