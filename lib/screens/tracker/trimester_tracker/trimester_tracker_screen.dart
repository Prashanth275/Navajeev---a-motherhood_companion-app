import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/trimester/trimester_provider.dart';
import '../../../widgets/trimester_widgets/babyinfo_card.dart';
import '../../../widgets/trimester_widgets/symptoms_card.dart';
import '../../../widgets/trimester_widgets/tips_card.dart';
import '../../../widgets/trimester_widgets/trimester_header_card.dart';

class TrimesterTrackerScreen extends StatefulWidget {
  const TrimesterTrackerScreen({super.key});

  @override
  State<TrimesterTrackerScreen> createState() =>
      _TrimesterTrackerScreenState();
}

class _TrimesterTrackerScreenState
    extends State<TrimesterTrackerScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TrimesterProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrimesterProvider>();
    final data = provider.currentWeekData;

    int trimester = 1;
    if (data != null) {
      trimester = _getTrimester(data.weekNumber);
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        toolbarHeight: 60,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: _getGradient(trimester),
          ),
        ),
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Trimester Tracker",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Track your pregnancy journey week by week",
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text(provider.error!))
          : _buildContent(provider),
    );
  }

  Widget _buildContent(TrimesterProvider provider) {
    final data = provider.currentWeekData!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 40,
        ),
        child: Column(
          children: [
            TrimesterDynamicHeader(
              currentWeek: data.weekNumber,
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BabyInfocard(data: data),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SymptomsCard(
                symptoms: data.symptoms,
                weekNumber: data.weekNumber,
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TipsCard(
                tips: data.tips,
                weekNumber: data.weekNumber,
                importantNote: data.importantNote,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  int _getTrimester(int week) {
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  LinearGradient _getGradient(int trimester) {
    switch (trimester) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFF8BBD0), Color(0xFFF48FB1)],
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFFFFCC80), Color(0xFFFFA726)],
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFFCE93D8), Color(0xFFBA68C8)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFFBA4DD), Color(0xFFFFE1F4)],
        );
    }
  }
}