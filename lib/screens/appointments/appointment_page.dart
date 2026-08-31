import 'package:flutter/material.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../widgets/appointment_widgets/appointment_tracker_view.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final babyId = user?.activeBabyId;

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
    );
  }
}