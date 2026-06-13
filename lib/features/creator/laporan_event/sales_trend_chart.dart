import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pentasera_app/main.dart';

/// Area/line chart widget showing daily ticket sales trend.
///
/// Expects [dailySales] to be a list of maps with keys:
///   - `date` (String, parseable by DateTime.parse)
///   - `orders` (int or String-parseable int)
class SalesTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailySales;

  const SalesTrendChart({super.key, required this.dailySales});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    if (dailySales.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, size: 40, color: mutedColor.withOpacity(0.4)),
              const SizedBox(height: 8),
              Text(
                'Belum ada data penjualan',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Parse data
    final spots = <FlSpot>[];
    final dateLabels = <int, String>{};

    for (int i = 0; i < dailySales.length; i++) {
      final entry = dailySales[i];
      final orders = _parseNum(entry['orders']);
      spots.add(FlSpot(i.toDouble(), orders.toDouble()));

      try {
        final date = DateTime.parse(entry['date'].toString());
        dateLabels[i] = DateFormat('dd MMM').format(date);
      } catch (_) {
        dateLabels[i] = entry['date']?.toString() ?? '';
      }
    }

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yMax = (maxY < 1) ? 1.0 : (maxY * 1.3).ceilToDouble();

    // Decide how many x-axis labels to show (max 6)
    final totalPoints = spots.length;
    final labelStep = (totalPoints / 6).ceil().clamp(1, totalPoints);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: yMax,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (yMax / 4).clamp(1, double.infinity),
            getDrawingHorizontalLine: (value) => FlLine(
              color: mutedColor.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: (yMax / 4).clamp(1, double.infinity),
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value < 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= totalPoints) return const SizedBox.shrink();
                  if (idx % labelStep != 0 && idx != totalPoints - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dateLabels[idx] ?? '',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => isDark
                  ? AppColors.surfaceDark
                  : Colors.white,
              tooltipBorder: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final idx = spot.x.toInt();
                  final label = dateLabels[idx] ?? '';
                  return LineTooltipItem(
                    '$label\n${spot.y.toInt()} order',
                    TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ),
    );
  }

  int _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
