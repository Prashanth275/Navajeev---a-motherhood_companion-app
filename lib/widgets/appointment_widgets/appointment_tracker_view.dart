import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'appointment_sheet.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../services/auth_service.dart';

class AppointmentTrackerView extends StatelessWidget {
  final List<Appointment> appointments;
  final String? babyId;

  const AppointmentTrackerView({
    super.key,
    required this.appointments,
    this.babyId,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = appointments.where((a) => !a.isCompleted).toList();
    final past = appointments.where((a) => a.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSummaryCard(
                title: "Upcoming",
                count: upcoming.length,
                icon: Icons.calendar_today_outlined,
                iconBg: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 20),
              _buildSummaryCard(
                title: "Completed",
                count: past.length,
                icon: Icons.check_circle_outline,
                iconBg: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF9575CD),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader("Upcoming"),
          const SizedBox(height: 12),
          _buildAppointmentList(context, upcoming, "No upcoming appointments"),
          const SizedBox(height: 32),
          _buildSectionHeader("Past Appointments"),
          const SizedBox(height: 12),
          _buildAppointmentList(context, past, "No past appointments", isPast: true),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () => _showAddAppointmentSheet(context, babyId),
              icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
              label: const Text(
                "New Appointment",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 16),
            Text("$count", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildAppointmentList(BuildContext context, List<Appointment> list, String emptyMsg, {bool isPast = false}) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text(emptyMsg, style: TextStyle(color: Colors.grey.shade400))),
      );
    }
    return Column(children: list.map((apt) => _buildAppointmentItem(context, apt, isPast)).toList());
  }

  Widget _buildAppointmentItem(BuildContext context, Appointment apt, bool isPast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPast ? const Color(0xFFFBFBFB) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetails(context, apt),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.read<AuthService>().toggleAppointmentStatus(apt.id, apt.isCompleted, babyId),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: apt.isCompleted ? const Color(0xFFE8F5E9) : Colors.transparent,
                    border: Border.all(color: apt.isCompleted ? Colors.green : Colors.grey.shade300),
                  ),
                  child: Icon(Icons.check, size: 16, color: apt.isCompleted ? Colors.green : Colors.transparent),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(apt.reason,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: isPast ? TextDecoration.lineThrough : null)),
                    Text("${DateFormat('MMM d').format(apt.scheduledAt)} at ${DateFormat('h:mm a').format(apt.scheduledAt)}",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, Appointment apt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: controller,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                const Text("Appointment Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                _detailRow(Icons.description, "Reason", apt.reason),
                _detailRow(Icons.person, "Doctor", apt.doctorName),
                _detailRow(Icons.local_hospital, "Hospital", apt.hospitalName),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: apt.isCompleted ? Colors.grey[200] : const Color(0xFF4CAF50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await context.read<AuthService>().toggleAppointmentStatus(
                        apt.id,
                        apt.isCompleted,
                        babyId,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: Icon(apt.isCompleted ? Icons.undo : Icons.check_circle, color: apt.isCompleted ? Colors.black54 : Colors.white),
                    label: Text(apt.isCompleted ? "Mark as Incomplete" : "Mark as Completed",
                        style: TextStyle(color: apt.isCompleted ? Colors.black54 : Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Icon(icon, size: 22, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ])
      ]),
    );
  }

  void _showAddAppointmentSheet(BuildContext context, String? babyId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => AddAppointmentSheet(babyId: babyId),
    );
  }
}