import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import 'package:navajeev_m/models/growth_record_model.dart';
import 'package:navajeev_m/services/growth/growth_analyzer.dart';

class BabyInfoCard extends StatelessWidget {
  final BabyDetails baby;
  final GrowthRecord?  latestRecord;

  const BabyInfoCard({
    super.key,
    required this.baby,
    required this.latestRecord,
  });

  @override
  Widget build(BuildContext context) {
    final ageText = _ageText(baby.dateOfBirth);
    final status = latestRecord?.overallStatus;
    final record = latestRecord;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: _statusBg(status),
              child: Icon(
                Icons.child_care,
                color: _statusColor(status),
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    baby.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$ageText • ${_statusLabel(status)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _statusColor(status),
                    ),
                  ),
                  if (record != null && record.concerns.isNotEmpty)
                    ...record.concerns.map(
                          (c) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "• $c",
                          style: TextStyle(
                            fontSize: 12,
                            color: _statusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  String _ageText(DateTime dob) {
    final days = DateTime.now().difference(dob).inDays;
    final months = (days / 30.4).floor();

    if (months < 1) return '$days days';
    if (months >= 12) {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      return remainingMonths == 0 ? '$years y' : '$years y $remainingMonths m';
    }
    return '$months months';
  }

  String _statusLabel(GrowthStatus? status) {
    if (status == null) return 'No data yet';
    return status.label;
  }

  Color _statusColor(GrowthStatus? status) {
    if (status == null) return Colors.grey;
    switch (status) {
      case GrowthStatus.normal:
        return Colors.green;
      case GrowthStatus.aboveNormal:
        return Colors.orange;
      case GrowthStatus.belowNormal:
        return Colors.red;
    }
  }

  Color _statusBg(GrowthStatus? status) {
    return _statusColor(status).withValues(alpha: 0.12);
  }
}
