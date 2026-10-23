import 'transaction.dart';

enum PeriodType { monthly, threeMonths, yearly }

class CategoryStat {
  final String categoryName;
  final double amount;
  final double percentage; // 0.0 to 100.0
  final int count;
  final String type; // 'income' or 'expense'

  const CategoryStat({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.count,
    required this.type,
  });
}

class MonthlyStat {
  final int year;
  final int month;
  final String monthName; // e.g. "Okt", "Oktober"
  final double income;
  final double expense;
  final double netBalance;
  final int transactionCount;

  const MonthlyStat({
    required this.year,
    required this.month,
    required this.monthName,
    required this.income,
    required this.expense,
    required this.netBalance,
    required this.transactionCount,
  });
}

class DailyStat {
  final DateTime date;
  final double income;
  final double expense;

  const DailyStat({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class PeriodComparison {
  final double previousIncome;
  final double previousExpense;
  final double previousNetBalance;
  final double? incomeChangePercentage; // null if previous was 0
  final double? expenseChangePercentage;

  const PeriodComparison({
    required this.previousIncome,
    required this.previousExpense,
    required this.previousNetBalance,
    this.incomeChangePercentage,
    this.expenseChangePercentage,
  });
}

class PeriodStatistics {
  final PeriodType periodType;
  final DateTime startDate;
  final DateTime endDate;
  final String periodTitle;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final int transactionCount;
  final List<CategoryStat> expenseCategories;
  final List<CategoryStat> incomeCategories;
  final List<MonthlyStat> monthlyBreakdown;
  final List<DailyStat> dailyBreakdown;
  final PeriodComparison? comparison;
  final String? highestIncomeMonth;
  final double highestIncomeAmount;
  final String? highestExpenseMonth;
  final double highestExpenseAmount;
  final String expenseTrend; // 'naik', 'turun', 'stabil'
  final List<Transaction> transactions;

  const PeriodStatistics({
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.periodTitle,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.transactionCount,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.monthlyBreakdown,
    required this.dailyBreakdown,
    this.comparison,
    this.highestIncomeMonth,
    this.highestIncomeAmount = 0.0,
    this.highestExpenseMonth,
    this.highestExpenseAmount = 0.0,
    this.expenseTrend = 'stabil',
    required this.transactions,
  });
}
