import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vaccine_model.dart';
import '../../theme/app_colors.dart';

enum VaccineCardStyle { featured, list, completed }

class VaccineCard extends StatelessWidget {
  final Vaccine vaccine;
  final DateTime babyDob;
  final VoidCallback onMarkAsDone;
  final VaccineCardStyle style;

  const VaccineCard({
    super.key,
    required this.vaccine,
    required this.babyDob,
    required this.onMarkAsDone,
    this.style = VaccineCardStyle.list,
  });


  @override
  Widget build(BuildContext context) {
    switch (style) {
      case VaccineCardStyle.featured:
        return _buildFeaturedCard(context);
      case VaccineCardStyle.list:
        return _buildListCard(context);
      case VaccineCardStyle.completed:
        return _buildCompletedCard(context);
    }
  }

  Widget _buildFeaturedCard(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final dueDate = vaccine.getDueDate(babyDob);

    return GestureDetector(
      onTap: () => _showVaccineDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.medicalBlush,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high,
                    color: AppColors.primaryAccent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Next Vaccination Due",
                  style: TextStyle(
                    color: AppColors.primaryAccent.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccine.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${dateFormat.format(dueDate)}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onMarkAsDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryAccent,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        "Mark done",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// LIST CARD
  Widget _buildListCard(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final dueDate = vaccine.getDueDate(babyDob);

    return GestureDetector(
      onTap: () => _showVaccineDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.medicalBlush,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.circle,
              color: AppColors.primaryAccent.withValues(alpha: 0.4),
              size: 12,
            ),
          ),
          title: Text(
            vaccine.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${vaccine.milestone} • Due ${dateFormat.format(dueDate)}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

// COMPLETED CARD
  Widget _buildCompletedCard(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.medicalMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Completed on ${vaccine.actualDate != null ? dateFormat
                      .format(vaccine.actualDate!) : "Unknown"}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            color: Colors.grey,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _listSection({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map(
              (e) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $e',
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ),
        ),
      ],
    );
  }

// DETAILS MODAL
  void _showVaccineDetails(BuildContext context) {
    final isDone =
        vaccine.getStatus(babyDob) == VaccineStatus.done;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Vaccine name
                  Text(
                    vaccine.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Milestone
                  Text(
                    vaccine.milestone,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Protection
                  if (vaccine.protection != null ||
                      vaccine.description != null) ...[
                    _detailSection(
                      title: 'Protects Against',
                      content:
                      vaccine.protection ??
                          vaccine.description!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Side Effects
                  if (vaccine.sideEffects != null &&
                      vaccine.sideEffects!.isNotEmpty) ...[
                    _listSection(
                      title: 'Possible Side Effects',
                      items: vaccine.sideEffects!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Care
                  if (vaccine.care != null) ...[
                    _detailSection(
                      title: 'Care & Comfort',
                      content: vaccine.care!,
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Button
                  if (!isDone)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onMarkAsDone();
                        },
                        child: const Text('Mark as Administered'),
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }
}