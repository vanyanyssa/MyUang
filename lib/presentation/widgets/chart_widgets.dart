import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/financial_statistics.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  final List<MonthlyStat> monthlyStats;

  const IncomeExpenseBarChart({super.key, required this.monthlyStats});

  @override
  Widget build(BuildContext context) {
    if (monthlyStats.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Tidak ada data grafik')),
      );
    }

    double maxY = 0;
    for (final s in monthlyStats) {
      if (s.income > maxY) maxY = s.income;
      if (s.expense > maxY) maxY = s.expense;
    }
    if (maxY == 0) maxY = 100000;
    maxY = maxY * 1.15; // add headroom

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == maxY) return const SizedBox.shrink();
                  return Text(
                    CurrencyFormatter.formatCompact(value),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < monthlyStats.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        monthlyStats[index].monthName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? Colors.white10 : Colors.black12,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(monthlyStats.length, (i) {
            final item = monthlyStats[i];
            return BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: item.income,
                  color: Colors.green,
                  width: monthlyStats.length > 6 ? 8 : 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: item.expense,
                  color: Colors.redAccent,
                  width: monthlyStats.length > 6 ? 8 : 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class FinancialTrendLineChart extends StatelessWidget {
  final List<MonthlyStat> stats;

  const FinancialTrendLineChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Tidak ada data tren')),
      );
    }

    double maxY = 0;
    for (final s in stats) {
      if (s.income > maxY) maxY = s.income;
      if (s.expense > maxY) maxY = s.expense;
    }
    if (maxY == 0) maxY = 100000;
    maxY = maxY * 1.15;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final incomeSpots = List.generate(
      stats.length,
      (i) => FlSpot(i.toDouble(), stats[i].income),
    );
    final expenseSpots = List.generate(
      stats.length,
      (i) => FlSpot(i.toDouble(), stats[i].expense),
    );

    return AspectRatio(
      aspectRatio: 1.6,
      child: LineChart(
        LineChartData(
          maxY: maxY,
          minY: 0,
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value >= maxY) return const SizedBox.shrink();
                  return Text(
                    CurrencyFormatter.formatCompact(value),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < stats.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        stats[index].monthName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? Colors.white10 : Colors.black12,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withValues(alpha: 0.1),
              ),
            ),
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: Colors.redAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryDonutChart extends StatelessWidget {
  final List<CategoryStat> categoryStats;

  const CategoryDonutChart({super.key, required this.categoryStats});

  @override
  Widget build(BuildContext context) {
    if (categoryStats.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text('Tidak ada pengeluaran pada periode ini'),
      );
    }

    final topCategories = categoryStats.take(6).toList();

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: topCategories.map((cat) {
                final color = AppCategories.getCategoryColor(cat.categoryName);
                return PieChartSectionData(
                  color: color,
                  value: cat.amount,
                  title: '${cat.percentage.toStringAsFixed(1)}%',
                  radius: 46,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: topCategories.map((cat) {
            final color = AppCategories.getCategoryColor(cat.categoryName);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  '${cat.categoryName} (${CurrencyFormatter.format(cat.amount)})',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
