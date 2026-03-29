import 'package:flutter/material.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:navajeev_m/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../widgets/appointment_widgets/appointment_sheet.dart';
import '../../widgets/appointment_widgets/appointment_tracker_view.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final babyId = user?.activeBabyId;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      extendBody: true,
      body: StreamBuilder<List<Appointment>>(
        stream: auth.getAppointments(babyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading appointments: ${snapshot.error}'),
            );
          }

          final appointments = snapshot.data ?? [];

          return AppointmentTrackerView(
            appointments: appointments,
            babyId: babyId,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAppointmentSheet(context, babyId),
        label: const Text("New Appointment"),
        icon: const Icon(Icons.add_alert_rounded),
        backgroundColor: AppColors.primaryAccent,
      ),
      bottomNavigationBar: isMobile ? const SizedBox(height: 90) : null,
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