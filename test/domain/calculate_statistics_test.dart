import 'package:flutter_test/flutter_test.dart';
import 'package:myuang/domain/entities/financial_statistics.dart';
import 'package:myuang/domain/entities/transaction.dart';
import 'package:myuang/domain/usecases/calculate_statistics.dart';

void main() {
  group('FinancialStatisticsCalculator Tests', () {
    final sampleTransactions = [
      // Oktober 2026
      Transaction(
        id: '1',
        type: 'income',
        amount: 5000000,
        category: 'Gaji',
        note: 'Gaji bulanan',
        date: DateTime(2026, 10, 1, 10, 0),
      ),
      Transaction(
        id: '2',
        type: 'expense',
        amount: 1500000,
        category: 'Makanan',
        note: 'Makan sehari-hari',
        date: DateTime(2026, 10, 5, 12, 30),
      ),
      Transaction(
        id: '3',
        type: 'expense',
        amount: 500000,
        category: 'Transportasi',
        note: 'Bensin & tol',
        date: DateTime(2026, 10, 10, 8, 0),
      ),
      // September 2026 (previous month)
      Transaction(
        id: '4',
        type: 'income',
        amount: 4500000,
        category: 'Gaji',
        note: 'Gaji September',
        date: DateTime(2026, 9, 1, 10, 0),
      ),
      Transaction(
        id: '5',
        type: 'expense',
        amount: 1800000,
        category: 'Makanan',
        note: 'Makan September',
        date: DateTime(2026, 9, 15, 12, 0),
      ),
      // Agustus 2026
      Transaction(
        id: '6',
        type: 'income',
        amount: 4000000,
        category: 'Gaji',
        note: 'Gaji Agustus',
        date: DateTime(2026, 8, 1, 10, 0),
      ),
      Transaction(
        id: '7',
        type: 'expense',
        amount: 2000000,
        category: 'Belanja',
        note: 'Belanja Agustus',
        date: DateTime(2026, 8, 20, 15, 0),
      ),
    ];

    test('calculateMonthly calculates accurate income, expense, and net balance', () {
      final stats = FinancialStatisticsCalculator.calculateMonthly(
        allTransactions: sampleTransactions,
        year: 2026,
        month: 10,
      );

      expect(stats.periodType, PeriodType.monthly);
      expect(stats.totalIncome, 5000000);
      expect(stats.totalExpense, 2000000);
      expect(stats.netBalance, 3000000);
      expect(stats.transactionCount, 3);
      expect(stats.expenseCategories.length, 2);
      expect(stats.expenseCategories[0].categoryName, 'Makanan');
      expect(stats.expenseCategories[0].amount, 1500000);
      expect(stats.expenseCategories[0].percentage, 75.0);
      expect(stats.expenseCategories[1].categoryName, 'Transportasi');
      expect(stats.expenseCategories[1].amount, 500000);
      expect(stats.expenseCategories[1].percentage, 25.0);

      // Previous month comparison (September 2026)
      expect(stats.comparison, isNotNull);
      expect(stats.comparison!.previousIncome, 4500000);
      expect(stats.comparison!.previousExpense, 1800000);
      expect(stats.comparison!.previousNetBalance, 2700000);
    });

    test('calculateThreeMonths computes rolling 3 months ending in October 2026', () {
      final stats = FinancialStatisticsCalculator.calculateThreeMonths(
        allTransactions: sampleTransactions,
        endYear: 2026,
        endMonth: 10,
      );

      expect(stats.periodType, PeriodType.threeMonths);
      // August (4M inc, 2M exp) + Sept (4.5M inc, 1.8M exp) + Oct (5M inc, 2M exp)
      expect(stats.totalIncome, 13500000);
      expect(stats.totalExpense, 5800000);
      expect(stats.netBalance, 7700000);
      expect(stats.transactionCount, 7);
      expect(stats.monthlyBreakdown.length, 3);
      expect(stats.monthlyBreakdown[0].month, 8); // August
      expect(stats.monthlyBreakdown[1].month, 9); // September
      expect(stats.monthlyBreakdown[2].month, 10); // October
    });

    test('calculateThreeMonths handles year boundary transition (e.g. Jan 2026 -> Nov 2025, Dec 2025, Jan 2026)', () {
      final crossYearTxs = [
        Transaction(
          id: '10',
          type: 'income',
          amount: 1000000,
          category: 'Gaji',
          note: 'Nov 2025',
          date: DateTime(2025, 11, 15),
        ),
        Transaction(
          id: '11',
          type: 'income',
          amount: 2000000,
          category: 'Gaji',
          note: 'Des 2025',
          date: DateTime(2025, 12, 15),
        ),
        Transaction(
          id: '12',
          type: 'income',
          amount: 3000000,
          category: 'Gaji',
          note: 'Jan 2026',
          date: DateTime(2026, 1, 15),
        ),
      ];

      final stats = FinancialStatisticsCalculator.calculateThreeMonths(
        allTransactions: crossYearTxs,
        endYear: 2026,
        endMonth: 1,
      );

      expect(stats.periodType, PeriodType.threeMonths);
      expect(stats.totalIncome, 6000000);
      expect(stats.totalExpense, 0);
      expect(stats.monthlyBreakdown.length, 3);
      expect(stats.monthlyBreakdown[0].year, 2025);
      expect(stats.monthlyBreakdown[0].month, 11);
      expect(stats.monthlyBreakdown[1].year, 2025);
      expect(stats.monthlyBreakdown[1].month, 12);
      expect(stats.monthlyBreakdown[2].year, 2026);
      expect(stats.monthlyBreakdown[2].month, 1);
    });

    test('calculateYearly computes full 12-month summary and highest months', () {
      final stats = FinancialStatisticsCalculator.calculateYearly(
        allTransactions: sampleTransactions,
        year: 2026,
      );

      expect(stats.periodType, PeriodType.yearly);
      expect(stats.totalIncome, 13500000);
      expect(stats.totalExpense, 5800000);
      expect(stats.netBalance, 7700000);
      expect(stats.monthlyBreakdown.length, 12);
      expect(stats.highestIncomeMonth, 'Oktober');
      expect(stats.highestIncomeAmount, 5000000);
      expect(stats.highestExpenseMonth, 'Agustus');
      expect(stats.highestExpenseAmount, 2000000);
    });

    test('empty transactions returns clean zero statistics without crash', () {
      final stats = FinancialStatisticsCalculator.calculateMonthly(
        allTransactions: [],
        year: 2026,
        month: 10,
      );

      expect(stats.totalIncome, 0);
      expect(stats.totalExpense, 0);
      expect(stats.netBalance, 0);
      expect(stats.transactionCount, 0);
      expect(stats.expenseCategories, isEmpty);
      expect(stats.incomeCategories, isEmpty);
      expect(stats.transactions, isEmpty);
    });
  });
}
