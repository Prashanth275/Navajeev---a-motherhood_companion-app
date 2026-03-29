import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/wellbeing/wellbeing_model.dart';
import '../../theme/app_colors.dart';

class WeeklyTrendChart extends StatefulWidget {
  final List<WellbeingEntry> entries;

  const WeeklyTrendChart({
    super.key,
    required this.entries,
  });

  @override
  State<WeeklyTrendChart> createState() =>
      _WeeklyTrendChartState();
}

class _WeeklyTrendChartState
    extends State<WeeklyTrendChart>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(WeeklyTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries != oldWidget.entries) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlSpot> _generateSpots() {
    final List<FlSpot> spots = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      final dayEntries = widget.entries.where(
            (e) =>
        e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,
      ).toList();

      if (dayEntries.isNotEmpty) {
        final avgMood = dayEntries
            .map((e) => e.mood)
            .reduce((a, b) => a + b) /
            dayEntries.length;

        spots.add(
          FlSpot(
            (6 - i).toDouble(),
            avgMood.toDouble(),
          ),
        );
      }
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _generateSpots();
    final now = DateTime.now();

    if (spots.isEmpty) {
      return Card(
        elevation: 4,
        shadowColor: AppColors.softPinkShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox(
          height: 220,
          child: Center(
            child: Text(
              "No data for this week",
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shadowColor: AppColors.softPinkShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
        child: SizedBox(
          height: 250,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {

              final double currentX =
                  _animation.value * 6;

              final List<FlSpot> visibleSpots = [];

              for (int i = 0; i < spots.length; i++) {
                if (spots[i].x <= currentX) {
                  visibleSpots.add(spots[i]);
                } else if (i > 0 &&
                    spots[i - 1].x < currentX) {
                  final double t =
                      (currentX - spots[i - 1].x) /
                          (spots[i].x -
                              spots[i - 1].x);

                  final double interpolatedY =
                      spots[i - 1].y +
                          t *
                              (spots[i].y -
                                  spots[i - 1].y);

                  visibleSpots.add(
                    FlSpot(currentX, interpolatedY),
                  );
                  break;
                }
              }

              return LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 5,

                  lineTouchData: LineTouchData(
                    touchTooltipData:
                    LineTouchTooltipData(
                      getTooltipColor:
                          (touchedSpot) =>
                          AppColors.primaryAccent
                              .withValues(
                              alpha: 0.85),
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems:
                          (touchedSpots) {
                        return touchedSpots
                            .map((spot) {
                          return LineTooltipItem(
                            'Mood: ${spot.y.toInt()}/5',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine:
                        (value) => FlLine(
                      color: AppColors
                          .textSecondary
                          .withValues(
                          alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                    getDrawingVerticalLine:
                        (value) => FlLine(
                      color: AppColors
                          .textSecondary
                          .withValues(
                          alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),

                  titlesData: FlTitlesData(
                    rightTitles:
                    const AxisTitles(
                      sideTitles:
                      SideTitles(
                          showTitles:
                          false),
                    ),
                    topTitles:
                    const AxisTitles(
                      sideTitles:
                      SideTitles(
                          showTitles:
                          false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 28,
                        getTitlesWidget:
                            (value, meta) {
                          if (value % 1 != 0)
                            return const SizedBox
                                .shrink();

                          return Text(
                            value
                                .toInt()
                                .toString(),
                            style:
                            const TextStyle(
                              fontSize: 12,
                              color: AppColors
                                  .textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget:
                            (value, meta) {
                          final date =
                          now.subtract(
                            Duration(
                                days: 6 -
                                    value
                                        .toInt()),
                          );

                          return Padding(
                            padding:
                            const EdgeInsets
                                .only(
                                top: 8),
                            child: Text(
                              DateFormat('E')
                                  .format(
                                  date),
                              style:
                              const TextStyle(
                                fontSize: 12,
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors
                            .textSecondary
                            .withValues(
                            alpha: 0.4),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: AppColors
                            .textSecondary
                            .withValues(
                            alpha: 0.4),
                        width: 1,
                      ),
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: visibleSpots,
                      isCurved: true,
                      color: AppColors.mood,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter:
                            (spot, percent,
                            barData,
                            index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color:
                              AppColors.mood,
                              strokeWidth: 0,
                            ),
                      ),
                      belowBarData:
                      BarAreaData(
                          show: false),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}