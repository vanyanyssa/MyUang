import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/categories.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/financial_statistics.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/calculate_statistics.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_state.dart';
import '../widgets/chart_widgets.dart';
import 'pdf_preview_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousPeriod(PeriodType type) {
    setState(() {
      if (type == PeriodType.monthly) {
        if (_selectedMonth == 1) {
          _selectedMonth = 12;
          _selectedYear--;
        } else {
          _selectedMonth--;
        }
      } else if (type == PeriodType.threeMonths) {
        if (_selectedMonth <= 3) {
          _selectedMonth = _selectedMonth + 9;
          _selectedYear--;
        } else {
          _selectedMonth -= 3;
        }
      } else {
        _selectedYear--;
      }
    });
  }

  void _nextPeriod(PeriodType type) {
    setState(() {
      if (type == PeriodType.monthly) {
        if (_selectedMonth == 12) {
          _selectedMonth = 1;
          _selectedYear++;
        } else {
          _selectedMonth++;
        }
      } else if (type == PeriodType.threeMonths) {
        if (_selectedMonth >= 10) {
          _selectedMonth = _selectedMonth - 9;
          _selectedYear++;
        } else {
          _selectedMonth += 3;
        }
      } else {
        _selectedYear++;
      }
    });
  }

  PeriodStatistics _computeStats(List<Transaction> transactions, PeriodType type) {
    switch (type) {
      case PeriodType.monthly:
        return FinancialStatisticsCalculator.calculateMonthly(
          allTransactions: transactions,
          year: _selectedYear,
          month: _selectedMonth,
        );
      case PeriodType.threeMonths:
        return FinancialStatisticsCalculator.calculateThreeMonths(
          allTransactions: transactions,
          endYear: _selectedYear,
          endMonth: _selectedMonth,
        );
      case PeriodType.yearly:
        return FinancialStatisticsCalculator.calculateYearly(
          allTransactions: transactions,
          year: _selectedYear,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistik Keuangan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bulanan'),
            Tab(text: '3 Bulan'),
            Tab(text: 'Tahunan'),
          ],
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Terjadi kesalahan: ${state.message}'),
              ),
            );
          }

          final allTransactions = state is TransactionLoaded ? state.transactions : <Transaction>[];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPeriodTab(allTransactions, PeriodType.monthly),
              _buildPeriodTab(allTransactions, PeriodType.threeMonths),
              _buildPeriodTab(allTransactions, PeriodType.yearly),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodTab(List<Transaction> allTransactions, PeriodType type) {
    final stats = _computeStats(allTransactions, type);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector header
          _buildPeriodSelectorHeader(stats, type),
          const SizedBox(height: 16),

          // Overview cards (Pemasukan, Pengeluaran, Saldo Bersih, Transaksi)
          _buildOverviewCards(stats),
          const SizedBox(height: 16),

          // Comparison and Trend card (if comparison is available)
          if (stats.comparison != null) ...[
            _buildComparisonCard(stats),
            const SizedBox(height: 16),
          ],

          // Yearly special info (highest income/expense month)
          if (type == PeriodType.yearly &&
              (stats.highestIncomeMonth != null || stats.highestExpenseMonth != null)) ...[
            _buildYearlyHighlights(stats),
            const SizedBox(height: 16),
          ],

          // Export PDF Card Button
          _buildExportPdfBanner(stats),
          const SizedBox(height: 20),

          // Chart 1: Bar Chart
          _buildSectionCard(
            title: type == PeriodType.monthly
                ? 'Perbandingan Pemasukan & Pengeluaran'
                : 'Pemasukan & Pengeluaran per Bulan',
            subtitle: 'Grafik batang pemasukan (hijau) vs pengeluaran (merah)',
            child: IncomeExpenseBarChart(monthlyStats: stats.monthlyBreakdown),
          ),
          const SizedBox(height: 20),

          // Chart 2: Trend Line Chart (for 3 months or yearly)
          if (stats.monthlyBreakdown.length > 1) ...[
            _buildSectionCard(
              title: 'Tren Keuangan',
              subtitle: 'Pergerakan arus kas selama periode',
              child: FinancialTrendLineChart(stats: stats.monthlyBreakdown),
            ),
            const SizedBox(height: 20),
          ],

          // Chart 3: Category Donut Chart
          _buildSectionCard(
            title: 'Kategori Pengeluaran',
            subtitle: 'Distribusi dan proporsi alokasi pengeluaran',
            child: CategoryDonutChart(categoryStats: stats.expenseCategories),
          ),
          const SizedBox(height: 20),

          // Category breakdown details table
          if (stats.expenseCategories.isNotEmpty) ...[
            _buildCategoryBreakdownList(stats.expenseCategories),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodSelectorHeader(PeriodStatistics stats, PeriodType type) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Periode Sebelumnya',
              onPressed: () => _previousPeriod(type),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    stats.periodTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormatter.formatNumeric(stats.startDate)} - ${DateFormatter.formatNumeric(stats.endDate)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Periode Berikutnya',
              onPressed: () => _nextPeriod(type),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(PeriodStatistics stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Pemasukan',
                amount: stats.totalIncome,
                color: Colors.green,
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Pengeluaran',
                amount: stats.totalExpense,
                color: Colors.red,
                icon: Icons.arrow_upward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Saldo Bersih',
                amount: stats.netBalance,
                color: stats.netBalance >= 0 ? Colors.indigo : Colors.red.shade800,
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_outlined, size: 16, color: Colors.blueGrey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'Transaksi',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.transactionCount}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(PeriodStatistics stats) {
    final comp = stats.comparison!;
    final expenseDiff = stats.totalExpense - comp.previousExpense;
    final isExpenseHigher = expenseDiff > 0;

    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isExpenseHigher ? Colors.red.shade50 : Colors.green.shade50,
              child: Icon(
                isExpenseHigher ? Icons.trending_up : Icons.trending_down,
                color: isExpenseHigher ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perbandingan Periode Sebelumnya',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comp.expenseChangePercentage != null
                        ? 'Pengeluaran ${comp.expenseChangePercentage! >= 0 ? "naik" : "turun"} ${comp.expenseChangePercentage!.abs().toStringAsFixed(1)}% (Sebelumnya: ${CurrencyFormatter.format(comp.previousExpense)})'
                        : 'Belum ada data periode sebelumnya untuk dibandingkan.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyHighlights(PeriodStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sorotan Tahunan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            if (stats.highestIncomeMonth != null && stats.highestIncomeAmount > 0)
              Row(
                children: [
                  const Icon(Icons.star_outline, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pemasukan Tertinggi: ${stats.highestIncomeMonth} (${CurrencyFormatter.format(stats.highestIncomeAmount)})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            if (stats.highestExpenseMonth != null && stats.highestExpenseAmount > 0)
              Row(
                children: [
                  const Icon(Icons.warning_amber_outlined, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pengeluaran Tertinggi: ${stats.highestExpenseMonth} (${CurrencyFormatter.format(stats.highestExpenseAmount)})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportPdfBanner(PeriodStatistics stats) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfPreviewPage(statistics: stats),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ekspor Laporan PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Download / cetak laporan lengkap ${stats.periodTitle}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownList(List<CategoryStat> categoryStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rincian Pengeluaran per Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoryStats.length,
              separatorBuilder: (_, _) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final cat = categoryStats[index];
                final catInfo = AppCategories.getCategoryInfo(cat.categoryName, 'expense');

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: catInfo.color.withValues(alpha: 0.15),
                      child: Icon(catInfo.icon, size: 16, color: catInfo.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.categoryName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${cat.count} transaksi (${cat.percentage.toStringAsFixed(1)}%)',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(cat.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
