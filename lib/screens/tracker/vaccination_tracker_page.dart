import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vaccine_providers.dart';
import '../../services/auth_service.dart';
import '../../widgets/vaccine_widgets/vaccine_card.dart';
import '../../theme/app_colors.dart';
import '../../models/vaccine_model.dart';

class VaccinationTrackerPage extends StatefulWidget {
  const VaccinationTrackerPage({super.key});

  @override
  State<VaccinationTrackerPage> createState() =>
      _VaccinationTrackerPageState();
}

class _VaccinationTrackerPageState extends State<VaccinationTrackerPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;

    final babyId = user.activeBabyId;
    final babyDob = user.babyDob;

    if (babyId != null && babyDob != null) {
      context.read<VaccineProvider>().initialize(
        babyId: babyId,
        babyDob: babyDob,
      );
      _initialized = true;
    }
  }

  Future<void> _markAsDone(String vaccineId) async {
    final provider =
    Provider.of<VaccineProvider>(context, listen: false);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      await provider.markAsDone(vaccineId, pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
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
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final vaccines = provider.vaccines;
          final upcoming = vaccines
              .where((v) => v.actualDate == null)
              .toList();

          final completed = vaccines
              .where((v) => v.actualDate != null)
              .toList();

          Vaccine? nextDue;
          List<Vaccine> remaining = [];

          if (upcoming.isNotEmpty) {
            nextDue = provider.nextUpcomingVaccine;
            remaining = upcoming.where((v) => v != nextDue).toList();
          }

          final babyDob = user!.babyDob!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProgressBar(provider),
              const SizedBox(height: 24),

              if (nextDue != null) ...[
                VaccineCard(
                  vaccine: nextDue,
                  babyDob: babyDob,
                  onMarkAsDone: () => _markAsDone(nextDue!.id),
                  style: VaccineCardStyle.featured,
                ),
                const SizedBox(height: 16),
              ],

              // Upcoming
              if (remaining.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Upcoming Vaccines',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...remaining.map(
                      (v) => VaccineCard(
                    vaccine: v,
                    babyDob: babyDob,
                    onMarkAsDone: () => _markAsDone(v.id),
                    style: VaccineCardStyle.list,
                  ),
                ),
              ],

              // Completed
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Completed Vaccines ✓',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...completed.map(
                      (v) => VaccineCard(
                    vaccine: v,
                    babyDob: babyDob,
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
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : completed / total,
                  backgroundColor: const Color(0xFFF0F0F0),
                  color: AppColors.success.withValues(alpha: 0.7),
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$percent%',
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
