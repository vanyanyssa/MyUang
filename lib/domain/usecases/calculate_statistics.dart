import '../../core/utils/date_formatter.dart';
import '../entities/financial_statistics.dart';
import '../entities/transaction.dart';

class FinancialStatisticsCalculator {
  /// Calculate monthly statistics for a given year and month (1-12)
  static PeriodStatistics calculateMonthly({
    required List<Transaction> allTransactions,
    required int year,
    required int month,
  }) {
    final startDate = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0).day;
    final endDate = DateTime(year, month, lastDay, 23, 59, 59, 999);

    final transactionsInPeriod = allTransactions.where((t) {
      return !t.date.isBefore(startDate) && !t.date.isAfter(endDate);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalIncome = _sumAmount(transactionsInPeriod, 'income');
    final totalExpense = _sumAmount(transactionsInPeriod, 'expense');
    final netBalance = totalIncome - totalExpense;

    final expenseCategories = _calculateCategoryStats(transactionsInPeriod, 'expense', totalExpense);
    final incomeCategories = _calculateCategoryStats(transactionsInPeriod, 'income', totalIncome);

    // Daily breakdown for the month
    final dailyMap = <int, DailyStat>{};
    for (int day = 1; day <= lastDay; day++) {
      dailyMap[day] = DailyStat(
        date: DateTime(year, month, day),
        income: 0.0,
        expense: 0.0,
      );
    }
    for (final t in transactionsInPeriod) {
      final day = t.date.day;
      final current = dailyMap[day]!;
      if (t.isIncome) {
        dailyMap[day] = DailyStat(
          date: current.date,
          income: current.income + t.amount,
          expense: current.expense,
        );
      } else {
        dailyMap[day] = DailyStat(
          date: current.date,
          income: current.income,
          expense: current.expense + t.amount,
        );
      }
    }
    final dailyBreakdown = dailyMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Previous month comparison
    final prevMonthDate = DateTime(year, month - 1, 1);
    final prevYear = prevMonthDate.year;
    final prevMonth = prevMonthDate.month;
    final prevLastDay = DateTime(prevYear, prevMonth + 1, 0).day;
    final prevStartDate = DateTime(prevYear, prevMonth, 1);
    final prevEndDate = DateTime(prevYear, prevMonth, prevLastDay, 23, 59, 59, 999);

    final prevTransactions = allTransactions.where((t) {
      return !t.date.isBefore(prevStartDate) && !t.date.isAfter(prevEndDate);
    }).toList();

    final prevIncome = _sumAmount(prevTransactions, 'income');
    final prevExpense = _sumAmount(prevTransactions, 'expense');
    final prevNetBalance = prevIncome - prevExpense;

    final incomeChange = prevIncome > 0
        ? ((totalIncome - prevIncome) / prevIncome) * 100
        : null;
    final expenseChange = prevExpense > 0
        ? ((totalExpense - prevExpense) / prevExpense) * 100
        : null;

    final comparison = PeriodComparison(
      previousIncome: prevIncome,
      previousExpense: prevExpense,
      previousNetBalance: prevNetBalance,
      incomeChangePercentage: incomeChange,
      expenseChangePercentage: expenseChange,
    );

    String trend = 'stabil';
    if (prevExpense > 0) {
      if (totalExpense > prevExpense * 1.05) {
        trend = 'naik';
      } else if (totalExpense < prevExpense * 0.95) {
        trend = 'turun';
      }
    }

    return PeriodStatistics(
      periodType: PeriodType.monthly,
      startDate: startDate,
      endDate: endDate,
      periodTitle: '${DateFormatter.getMonthName(month)} $year',
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: netBalance,
      transactionCount: transactionsInPeriod.length,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
      monthlyBreakdown: [
        MonthlyStat(
          year: year,
          month: month,
          monthName: DateFormatter.getShortMonthName(month),
          income: totalIncome,
          expense: totalExpense,
          netBalance: netBalance,
          transactionCount: transactionsInPeriod.length,
        ),
      ],
      dailyBreakdown: dailyBreakdown,
      comparison: comparison,
      expenseTrend: trend,
      transactions: transactionsInPeriod,
    );
  }

  /// Calculate 3-month rolling statistics ending at endMonth/endYear
  /// Example: endMonth = 10 (Oct), endYear = 2026 -> Aug, Sep, Oct 2026
  /// Example: endMonth = 1 (Jan), endYear = 2026 -> Nov 2025, Dec 2025, Jan 2026
  static PeriodStatistics calculateThreeMonths({
    required List<Transaction> allTransactions,
    required int endYear,
    required int endMonth,
  }) {
    // 3 consecutive months: m1, m2, m3 (ending at endMonth)
    final m3Date = DateTime(endYear, endMonth, 1);
    final m2Date = DateTime(endYear, endMonth - 1, 1);
    final m1Date = DateTime(endYear, endMonth - 2, 1);

    final startDate = DateTime(m1Date.year, m1Date.month, 1);
    final m3LastDay = DateTime(endYear, endMonth + 1, 0).day;
    final endDate = DateTime(endYear, endMonth, m3LastDay, 23, 59, 59, 999);

    final transactionsInPeriod = allTransactions.where((t) {
      return !t.date.isBefore(startDate) && !t.date.isAfter(endDate);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalIncome = _sumAmount(transactionsInPeriod, 'income');
    final totalExpense = _sumAmount(transactionsInPeriod, 'expense');
    final netBalance = totalIncome - totalExpense;

    final expenseCategories = _calculateCategoryStats(transactionsInPeriod, 'expense', totalExpense);
    final incomeCategories = _calculateCategoryStats(transactionsInPeriod, 'income', totalIncome);

    // Monthly breakdown for each of the 3 months
    final monthDates = [m1Date, m2Date, m3Date];
    final monthlyBreakdown = <MonthlyStat>[];

    for (final mDate in monthDates) {
      final y = mDate.year;
      final m = mDate.month;
      final mStart = DateTime(y, m, 1);
      final mLastDay = DateTime(y, m + 1, 0).day;
      final mEnd = DateTime(y, m, mLastDay, 23, 59, 59, 999);

      final monthTxs = transactionsInPeriod.where((t) {
        return !t.date.isBefore(mStart) && !t.date.isAfter(mEnd);
      }).toList();

      final inc = _sumAmount(monthTxs, 'income');
      final exp = _sumAmount(monthTxs, 'expense');

      monthlyBreakdown.add(
        MonthlyStat(
          year: y,
          month: m,
          monthName: '${DateFormatter.getShortMonthName(m)}${y != endYear ? " '$y" : ""}',
          income: inc,
          expense: exp,
          netBalance: inc - exp,
          transactionCount: monthTxs.length,
        ),
      );
    }

    // Previous 3-month period comparison
    final prevM3Date = DateTime(endYear, endMonth - 3, 1);
    final prevM1Date = DateTime(endYear, endMonth - 5, 1);
    final prevStartDate = DateTime(prevM1Date.year, prevM1Date.month, 1);
    final prevM3LastDay = DateTime(prevM3Date.year, prevM3Date.month + 1, 0).day;
    final prevEndDate = DateTime(prevM3Date.year, prevM3Date.month, prevM3LastDay, 23, 59, 59, 999);

    final prevTransactions = allTransactions.where((t) {
      return !t.date.isBefore(prevStartDate) && !t.date.isAfter(prevEndDate);
    }).toList();

    final prevIncome = _sumAmount(prevTransactions, 'income');
    final prevExpense = _sumAmount(prevTransactions, 'expense');
    final prevNetBalance = prevIncome - prevExpense;

    final incomeChange = prevIncome > 0
        ? ((totalIncome - prevIncome) / prevIncome) * 100
        : null;
    final expenseChange = prevExpense > 0
        ? ((totalExpense - prevExpense) / prevExpense) * 100
        : null;

    final comparison = PeriodComparison(
      previousIncome: prevIncome,
      previousExpense: prevExpense,
      previousNetBalance: prevNetBalance,
      incomeChangePercentage: incomeChange,
      expenseChangePercentage: expenseChange,
    );

    // Trend analysis across the 3 months
    String trend = 'stabil';
    if (monthlyBreakdown.length == 3) {
      final firstExp = monthlyBreakdown[0].expense;
      final lastExp = monthlyBreakdown[2].expense;
      if (firstExp > 0) {
        if (lastExp > firstExp * 1.05) {
          trend = 'naik';
        } else if (lastExp < firstExp * 0.95) {
          trend = 'turun';
        }
      } else if (lastExp > 0) {
        trend = 'naik';
      }
    }

    final title = '${DateFormatter.getShortMonthName(m1Date.month)} ${m1Date.year != endYear ? m1Date.year : ""} - ${DateFormatter.getMonthName(endMonth)} $endYear'.trim();

    return PeriodStatistics(
      periodType: PeriodType.threeMonths,
      startDate: startDate,
      endDate: endDate,
      periodTitle: title,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: netBalance,
      transactionCount: transactionsInPeriod.length,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
      monthlyBreakdown: monthlyBreakdown,
      dailyBreakdown: const [],
      comparison: comparison,
      expenseTrend: trend,
      transactions: transactionsInPeriod,
    );
  }

  /// Calculate yearly statistics for a given year
  static PeriodStatistics calculateYearly({
    required List<Transaction> allTransactions,
    required int year,
  }) {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59, 999);

    final transactionsInPeriod = allTransactions.where((t) {
      return !t.date.isBefore(startDate) && !t.date.isAfter(endDate);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalIncome = _sumAmount(transactionsInPeriod, 'income');
    final totalExpense = _sumAmount(transactionsInPeriod, 'expense');
    final netBalance = totalIncome - totalExpense;

    final expenseCategories = _calculateCategoryStats(transactionsInPeriod, 'expense', totalExpense);
    final incomeCategories = _calculateCategoryStats(transactionsInPeriod, 'income', totalIncome);

    // 12-month breakdown
    final monthlyBreakdown = <MonthlyStat>[];
    String? highestIncomeMonth;
    double highestIncomeAmount = 0.0;
    String? highestExpenseMonth;
    double highestExpenseAmount = 0.0;

    for (int month = 1; month <= 12; month++) {
      final mStart = DateTime(year, month, 1);
      final mLastDay = DateTime(year, month + 1, 0).day;
      final mEnd = DateTime(year, month, mLastDay, 23, 59, 59, 999);

      final monthTxs = transactionsInPeriod.where((t) {
        return !t.date.isBefore(mStart) && !t.date.isAfter(mEnd);
      }).toList();

      final inc = _sumAmount(monthTxs, 'income');
      final exp = _sumAmount(monthTxs, 'expense');

      if (inc > highestIncomeAmount) {
        highestIncomeAmount = inc;
        highestIncomeMonth = DateFormatter.getMonthName(month);
      }
      if (exp > highestExpenseAmount) {
        highestExpenseAmount = exp;
        highestExpenseMonth = DateFormatter.getMonthName(month);
      }

      monthlyBreakdown.add(
        MonthlyStat(
          year: year,
          month: month,
          monthName: DateFormatter.getShortMonthName(month),
          income: inc,
          expense: exp,
          netBalance: inc - exp,
          transactionCount: monthTxs.length,
        ),
      );
    }

    // Previous year comparison
    final prevStartDate = DateTime(year - 1, 1, 1);
    final prevEndDate = DateTime(year - 1, 12, 31, 23, 59, 59, 999);

    final prevTransactions = allTransactions.where((t) {
      return !t.date.isBefore(prevStartDate) && !t.date.isAfter(prevEndDate);
    }).toList();

    final prevIncome = _sumAmount(prevTransactions, 'income');
    final prevExpense = _sumAmount(prevTransactions, 'expense');
    final prevNetBalance = prevIncome - prevExpense;

    final incomeChange = prevIncome > 0
        ? ((totalIncome - prevIncome) / prevIncome) * 100
        : null;
    final expenseChange = prevExpense > 0
        ? ((totalExpense - prevExpense) / prevExpense) * 100
        : null;

    final comparison = PeriodComparison(
      previousIncome: prevIncome,
      previousExpense: prevExpense,
      previousNetBalance: prevNetBalance,
      incomeChangePercentage: incomeChange,
      expenseChangePercentage: expenseChange,
    );

    return PeriodStatistics(
      periodType: PeriodType.yearly,
      startDate: startDate,
      endDate: endDate,
      periodTitle: 'Tahun $year',
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: netBalance,
      transactionCount: transactionsInPeriod.length,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
      monthlyBreakdown: monthlyBreakdown,
      dailyBreakdown: const [],
      comparison: comparison,
      highestIncomeMonth: highestIncomeMonth,
      highestIncomeAmount: highestIncomeAmount,
      highestExpenseMonth: highestExpenseMonth,
      highestExpenseAmount: highestExpenseAmount,
      transactions: transactionsInPeriod,
    );
  }

  static double _sumAmount(List<Transaction> transactions, String type) {
    return transactions
        .where((t) => t.type == type)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  static List<CategoryStat> _calculateCategoryStats(
    List<Transaction> transactions,
    String type,
    double totalTypeAmount,
  ) {
    final filtered = transactions.where((t) => t.type == type).toList();
    if (filtered.isEmpty) return [];

    final categoryMap = <String, double>{};
    final countMap = <String, int>{};

    for (final t in filtered) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0.0) + t.amount;
      countMap[t.category] = (countMap[t.category] ?? 0) + 1;
    }

    final result = categoryMap.entries.map((entry) {
      final percentage = totalTypeAmount > 0
          ? (entry.value / totalTypeAmount) * 100
          : 0.0;
      return CategoryStat(
        categoryName: entry.key,
        amount: entry.value,
        percentage: percentage,
        count: countMap[entry.key] ?? 0,
        type: type,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return result;
  }
}
