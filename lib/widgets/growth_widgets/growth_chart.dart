import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:navajeev_m/models/growth_record_model.dart';
import 'package:navajeev_m/models/who_entry.dart';
import 'package:navajeev_m/services/growth/growth_analyzer.dart';
import 'package:navajeev_m/models/who_metric.dart';
import 'package:navajeev_m/services/vaccine/who_data_service.dart';
import 'package:navajeev_m/extensions/baby_gender_extensions.dart';
import '../../models/user_model.dart';

enum MetricKey { weight, length, head }

class GrowthChart extends StatefulWidget {
  final List<GrowthRecord> records;
  final DateTime birthDate;
  final BabyGender gender;

  const GrowthChart({
    super.key,
    required this.records,
    required this.birthDate,
    required this.gender,
  });

  @override
  State<GrowthChart> createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart> {
  MetricKey selectedMetric = MetricKey.weight;
  bool _animate = false;
  Future<List<WhoEntry>>? _whoFuture;

  @override
  void initState() {
    super.initState();

    _whoFuture = WhoDataService.load(
      genderKey: widget.gender.whoKey,
      metric: _getWhoMetric(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });
  }
  @override
  void didUpdateWidget(GrowthChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records.length != widget.records.length) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    if (!mounted) return;
    setState(() => _animate = false);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _animate = true);
    });
  }

  WhoMetric _getWhoMetric() {
    switch (selectedMetric) {
      case MetricKey.weight: return WhoMetric.weightForAge;
      case MetricKey.length: return WhoMetric.lengthForAge;
      case MetricKey.head: return WhoMetric.headCircumferenceForAge;
    }
  }

  Color _getMetricColor() {
    switch (selectedMetric) {
      case MetricKey.weight: return Colors.pink;
      case MetricKey.length: return Colors.blue;
      case MetricKey.head: return Colors.purple;
    }
  }

  String _getMetricLabel(MetricKey key) {
    switch (key) {
      case MetricKey.weight:
        return "WEIGHT";
      case MetricKey.length:
        return "HEIGHT";
      case MetricKey.head:
        return "HEAD";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text(
            "No growth data yet",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildMetricToggle(),
          const SizedBox(height: 16),

          SizedBox(
            height: 300,
            child: FutureBuilder<List<WhoEntry>>(
              future: _whoFuture,
              builder: (context, whoSnap) {
                if (!whoSnap.hasData) return const Center(child: CircularProgressIndicator());
                return LineChart(
                  _chartData(whoSnap.data!),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubic,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMetricToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: MetricKey.values.map((m) {
          final active = selectedMetric == m;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedMetric = m;
                _whoFuture = WhoDataService.load(
                  genderKey: widget.gender.whoKey,
                  metric: _getWhoMetric(),
                );
              });
              _triggerAnimation();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? _getMetricColor() : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                _getMetricLabel(m),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: active ? Colors.white : Colors.grey.shade600
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  LineChartData _chartData(List<WhoEntry> whoData) {
    final lastRecordDate = widget.records.isNotEmpty
        ? widget.records
        .map((r) => r.checkInDate)
        .reduce((a, b) => a.isAfter(b) ? a : b)
        : widget.birthDate;

    final currentAgeMonths =
        lastRecordDate.difference(widget.birthDate).inDays / 30.4375;
    final double dynamicMaxX =
    currentAgeMonths < 4 ? 4 : currentAgeMonths + 0.5;

    return LineChartData(
      minX: 0,
      maxX: dynamicMaxX,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      borderData: FlBorderData(show: false),
      titlesData: _buildTitles(),
      lineBarsData: [
        _sdLine(whoData, 3, Colors.transparent),
        _sdLine(whoData, 2, Colors.orange.withValues(alpha: 0.5)),
        _sdLine(whoData, -2, Colors.orange.withValues(alpha: 0.5)),
        _sdLine(whoData, -3, Colors.transparent),
        _babyLine(),
      ],
      betweenBarsData: [
        BetweenBarsData(fromIndex: 0, toIndex: 1, color: Colors.red.withValues(alpha: 0.05)),
        BetweenBarsData(fromIndex: 1, toIndex: 2, color: Colors.green.withValues(alpha: 0.1)),
        BetweenBarsData(fromIndex: 2, toIndex: 3, color: Colors.red.withValues(alpha: 0.05)),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.white,
          getTooltipItems: (spots) => spots
              .where((s) => s.barIndex == 4)
              .map((s) => LineTooltipItem(
            '${s.y.toStringAsFixed(1)} ${selectedMetric == MetricKey.weight ? "kg" : "cm"}',
            TextStyle(
              fontWeight: FontWeight.bold,
              color: _getMetricColor(),
            ),
          ))
              .toList(),
        ),
      ),

    );
  }

  LineChartBarData _sdLine(List<WhoEntry> data, double z, Color color) {
    return LineChartBarData(
      spots: data.map((e) => FlSpot(e.x / 30.4375, GrowthAnalyzer.valueAtZ(z: z, l: e.l, m: e.m, s: e.s))).toList(),
      isCurved: true,
      barWidth: 1,
      dashArray: [5, 5],
      dotData: const FlDotData(show: false),
      color: color,
    );
  }

  LineChartBarData _babyLine() {
    final sortedRecords = [...widget.records]..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));
    final Map<DateTime, GrowthRecord> dailyRecords = {};

    for (final record in sortedRecords) {
      final dayKey = DateTime(
        record.checkInDate.year,
        record.checkInDate.month,
        record.checkInDate.day,
      );
      dailyRecords[dayKey] = record;
    }
    final filteredRecords = dailyRecords.values.toList()
      ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

    final spots = filteredRecords.map((r) {
        final ageMonths = r.checkInDate.difference(widget.birthDate).inDays / 30.4375;
        double y;
        if (selectedMetric == MetricKey.weight) y = r.weightKg;
        else if (selectedMetric == MetricKey.length) y = r.lengthCm;
        else y = r.headCircumferenceCm ?? 0;

        final visibleY = _animate ? y : 0.0;

        return FlSpot(ageMonths, visibleY);
      }).toList();
    return LineChartBarData(
    spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      barWidth: 4,
      color: _getMetricColor(),
      dotData: FlDotData(
        show: true,
        getDotPainter: (s, p, b, i) => FlDotCirclePainter(
          radius: i == b.spots.length - 1 ? 6 : 4,
          color: Colors.white,
          strokeWidth: 3,
          strokeColor: _getMetricColor(),
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            _getMetricColor().withValues(alpha: 0.25),
            _getMetricColor().withValues(alpha: 0.08),
            _getMetricColor().withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (v, _) => Text('${v.toInt()}m', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(Colors.green.withValues(alpha: 0.5), 'Normal'),
        const SizedBox(width: 12),
        _dot(Colors.red.withValues(alpha: 0.5), 'Abnormal'),
        const SizedBox(width: 12),
        _dot(_getMetricColor(), 'Baby'),
      ],
    );
  }

  Widget _dot(Color c, String l) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);
}