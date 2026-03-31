import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../utils/constants.dart';
import 'app_styles.dart';

class FinancialChart extends StatelessWidget {
  const FinancialChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final results = provider.results;

    if (results == null ||
        results.cumulativeCost.isEmpty ||
        results.cumulativeReturns.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    const maxX = 25.0;
    double maxVal = 1;
    for (int i = 0; i < 25; i++) {
      if (results.cumulativeCost[i] > maxVal) {
        maxVal = results.cumulativeCost[i];
      }
      if (results.cumulativeReturns[i] > maxVal) {
        maxVal = results.cumulativeReturns[i];
      }
    }
    // Round up max val for Y-axis
    maxVal = maxVal * 1.1;

    List<FlSpot> costSpots = [];
    List<FlSpot> returnSpots = [];
    for (int i = 0; i < 25; i++) {
      costSpots.add(FlSpot((i + 1).toDouble(), results.cumulativeCost[i]));
      returnSpots.add(FlSpot((i + 1).toDouble(), results.cumulativeReturns[i]));
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withValues(alpha: 0.06),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
                getDrawingVerticalLine: (value) {
                  // highlight battery replacement years if needed
                  if (results.batteryReplacementYears.contains(value.toInt())) {
                    return FlLine(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      strokeWidth: 1.5,
                      dashArray: [5, 3],
                    );
                  }
                  return FlLine(
                    color: Colors.white.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text(
                    'Year',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Y${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 55,
                    interval: maxVal / 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        SolarConstants.formatINR(value),
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.end,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  left: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              ),
              minX: 0,
              maxX: maxX,
              minY: 0,
              maxY: maxVal,
              lineBarsData: [
                // Returns Line
                LineChartBarData(
                  spots: returnSpots,
                  isCurved: false,
                  color: AppColors.success,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      return spot.x == results.breakEvenYear;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: AppColors.gold,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withValues(alpha: 0.3),
                        AppColors.success.withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Cost Line
                LineChartBarData(
                  spots: costSpots,
                  isCurved: false,
                  color: AppColors.danger,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.danger.withValues(alpha: 0.3),
                        AppColors.danger.withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        SolarConstants.formatINR(spot.y, compact: false),
                        TextStyle(
                          color: spot.barIndex == 0 ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          children: [
            const _LegendItem(color: AppColors.danger, label: 'Cumulative Cost'),
            const _LegendItem(color: AppColors.success, label: 'Cumulative Returns'),
            if (provider.hasBattery)
              const _LegendItem(color: AppColors.gold, label: 'Battery Replace', isDashed: true),
          ],
        )
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
            border: isDashed ? Border.all(color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
