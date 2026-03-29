import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklySleepChart extends StatelessWidget {
  final List<double> weeklyHours;

  const WeeklySleepChart({
    super.key,
    required this.weeklyHours,
  });

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday - 1;

    final double maxValue = weeklyHours.isEmpty
        ? 0.0
        : weeklyHours.reduce((a, b) => a > b ? a : b);

    final double safeMax = maxValue < 6 ? 6 : (maxValue + 1).ceilToDouble();

    const dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      children: [
      SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: safeMax,

          /// TOOLTIP
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.white,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "${dayLabels[group.x]}\n",
                  const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "${rod.toY.toStringAsFixed(1)} hours",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          /// TITLES
          titlesData: FlTitlesData(
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dayLabels.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dayLabels[index],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),

          /// GRID
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            checkToShowHorizontalLine: (value) => value % 3 == 0,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withAlpha((0.2 * 255).toInt()),
              dashArray: [5, 5],
            ),
          ),

          /// BORDER
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                  color: Colors.grey.withAlpha((0.3 * 255).toInt())),
              left: BorderSide(
                  color: Colors.grey.withAlpha((0.3 * 255).toInt())),
            ),
          ),

          /// BARS
          barGroups: List.generate(7, (index) {
            final double hours = index < weeklyHours.length ? weeklyHours[index] : 0.0;

            final isToday = index == todayIndex;

            final baseColor = _getColorForHours(hours);

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: hours,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  color: isToday ? baseColor : baseColor.withAlpha((0.6 * 255).toInt()),
                ),
              ],
            );
          }),
        ),
      ),
      ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Color _getColorForHours(double hours) {
    if (hours < 6) return Colors.red;      // Poor
    if (hours < 7) return Colors.amber;    // Fair
    if (hours <= 9) return Colors.green;   // Good
    return Colors.blue;                    // Excellent
  }
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.red, "Poor"),
        const SizedBox(width: 16),
        _legendItem(Colors.amber, "Fair"),
        const SizedBox(width: 16),
        _legendItem(Colors.green, "Good"),
        const SizedBox(width: 16),
        _legendItem(Colors.blue, "Excellent"),
      ],
    );
  }
  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
