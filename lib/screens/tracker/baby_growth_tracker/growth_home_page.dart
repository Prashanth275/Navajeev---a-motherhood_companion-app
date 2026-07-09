import 'package:flutter/material.dart';
import 'package:navajeev_m/widgets/growth_widgets/growth_chart.dart';
import 'package:navajeev_m/widgets/growth_widgets/growth_summary_cards.dart';
import 'package:navajeev_m/services/growth/growth_fetch_service.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:navajeev_m/models/growth_record_model.dart';
import 'package:provider/provider.dart';
import '../../../extensions/baby_gender_extensions.dart';
import '../../../models/who_entry.dart';
import '../../../providers/growth/growth_provider.dart';
import '../../../widgets/growth_widgets/baby_info_card.dart';
import 'package:navajeev_m/models/who_metric.dart';
import 'package:navajeev_m/widgets/growth_widgets/growth_history_list.dart';
import 'package:navajeev_m/widgets/growth_widgets/add_growth_modal.dart';

class GrowthHomePage extends StatefulWidget {
  const GrowthHomePage({super.key});

  @override
  State<GrowthHomePage> createState() => _GrowthHomePageState();
}

class _GrowthHomePageState extends State<GrowthHomePage> {
  String _delta(double current, double previous, String unit) {
    final diff = current - previous;
    final sign = diff >= 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final baby = user?.babyDetails;
    final babyId = user?.activeBabyId;

    if (baby == null || babyId == null) {
      return const Scaffold(body: Center(child: Text('Baby profile not found')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Growth Tracker', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
      builder: (ctx) => AddGrowthModal(
        babyId: babyId!,
        baby: baby!,
      ),
            ),
            icon: const Icon(Icons.add_circle_outline, color: Colors.pink, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Builder(
        builder: (context) {
          final growthProvider = context.watch<GrowthProvider>();

          if (growthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = growthProvider.records.reversed.toList();
          final latest = growthProvider.latestRecord;
          final previous = records.length > 1 ? records[1] : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                BabyInfoCard(baby: baby, latestRecord: latest),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 450;

                    final cards = [
                      GrowthSummaryCard(
                        label: "Weight",
                        value: "${latest?.weightKg ?? '--'} kg",
                        trend: previous != null
                            ? _delta(latest!.weightKg, previous.weightKg, 'kg')
                            : "First",
                        iconColor: Colors.pink,
                        icon: Icons.monitor_weight_outlined,
                      ),
                      GrowthSummaryCard(
                        label: "Height",
                        value: "${latest?.lengthCm ?? '--'} cm",
                        trend: previous != null
                            ? _delta(latest!.lengthCm, previous.lengthCm, 'cm')
                            : "First",
                        iconColor: Colors.blue,
                        icon: Icons.height,
                      ),
                      GrowthSummaryCard(
                        label: "Head",
                        value: "${latest?.headCircumferenceCm ?? '--'} cm",
                        trend: latest != null ? "Updated" : "No data",
                        iconColor: Colors.purple,
                        icon: Icons.face_outlined,
                      ),
                    ];

                    return isNarrow
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: cards.map((card) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: SizedBox(
                                  width: 120,
                                  child: card,
                                ),
                              )).toList(),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(child: cards[0]),
                              const SizedBox(width: 8),
                              Expanded(child: cards[1]),
                              const SizedBox(width: 8),
                              Expanded(child: cards[2]),
                            ],
                          );
                  },
                ),

                const SizedBox(height: 20),

                GrowthChart(
                  records: growthProvider.records,
                  birthDate: baby.dateOfBirth,
                  gender: baby.gender,
                ),

                const SizedBox(height: 20),

                GrowthHistoryList(records: records),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}