import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myuang/domain/entities/transaction.dart';
import 'package:myuang/domain/repositories/settings_repository.dart';
import 'package:myuang/domain/repositories/transaction_repository.dart';
import 'package:myuang/domain/usecases/add_transaction.dart';
import 'package:myuang/domain/usecases/delete_transaction.dart';
import 'package:myuang/domain/usecases/get_transactions.dart';
import 'package:myuang/domain/usecases/update_transaction.dart';
import 'package:myuang/main.dart';

class MockTransactionRepo implements TransactionRepository {
  final List<Transaction> _list = [];

  @override
  Future<List<Transaction>> getTransactions() async => List.from(_list);

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _list.removeWhere((t) => t.id == transaction.id);
    _list.add(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final idx = _list.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) _list[idx] = transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _list.removeWhere((t) => t.id == id);
  }
}

class MockSettingsRepo implements SettingsRepository {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Future<ThemeMode> getThemeMode() async => _themeMode;

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('HomePage renders dashboard, navigation bar, and switches tabs', (tester) async {
    final txRepo = MockTransactionRepo();
    final settingsRepo = MockSettingsRepo();

    await txRepo.addTransaction(
      Transaction(
        id: 'tx-100',
        type: 'income',
        amount: 2000000,
        category: 'Gaji',
        note: 'Uang Saku',
        date: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MyUangApp(
        getTransactions: GetTransactions(txRepo),
        addTransaction: AddTransaction(txRepo),
        updateTransaction: UpdateTransaction(txRepo),
        deleteTransaction: DeleteTransaction(txRepo),
        settingsRepository: settingsRepo,
        initialTheme: ThemeMode.light,
      ),
    );

    await tester.pumpAndSettle();

    // Verify Dashboard is displayed
    expect(find.text('MyUang'), findsWidgets);
    expect(find.text('Total Saldo Kumulatif'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Transaksi'), findsWidgets);
    expect(find.text('Statistik'), findsWidgets);
    expect(find.text('Pengaturan'), findsWidgets);

    // Switch to Transaksi tab
    await tester.tap(find.text('Transaksi').last);
    await tester.pumpAndSettle();
    expect(find.text('Daftar Transaksi'), findsOneWidget);

    // Switch to Statistik tab
    await tester.tap(find.text('Statistik').last);
    await tester.pumpAndSettle();
    expect(find.text('Statistik Keuangan'), findsOneWidget);

    // Switch to Pengaturan tab
    await tester.tap(find.text('Pengaturan').last);
    await tester.pumpAndSettle();
    expect(find.text('TAMPILAN'), findsOneWidget);
    expect(find.text('PENYIMPANAN DATA'), findsOneWidget);
  });
}
