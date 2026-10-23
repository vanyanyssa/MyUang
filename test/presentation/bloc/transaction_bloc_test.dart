import 'package:flutter_test/flutter_test.dart';
import 'package:myuang/domain/entities/transaction.dart';
import 'package:myuang/domain/repositories/transaction_repository.dart';
import 'package:myuang/domain/usecases/add_transaction.dart';
import 'package:myuang/domain/usecases/delete_transaction.dart';
import 'package:myuang/domain/usecases/get_transactions.dart';
import 'package:myuang/domain/usecases/update_transaction.dart';
import 'package:myuang/presentation/bloc/transaction_bloc.dart';
import 'package:myuang/presentation/bloc/transaction_event.dart';
import 'package:myuang/presentation/bloc/transaction_state.dart';

class FakeTransactionRepository implements TransactionRepository {
  final List<Transaction> _items = [];

  @override
  Future<List<Transaction>> getTransactions() async {
    return List.from(_items);
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _items.removeWhere((t) => t.id == transaction.id);
    _items.add(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _items.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _items[index] = transaction;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _items.removeWhere((t) => t.id == id);
  }
}

void main() {
  group('TransactionBloc Tests', () {
    late FakeTransactionRepository repository;
    late TransactionBloc bloc;

    setUp(() {
      repository = FakeTransactionRepository();
      bloc = TransactionBloc(
        getTransactions: GetTransactions(repository),
        addTransaction: AddTransaction(repository),
        updateTransaction: UpdateTransaction(repository),
        deleteTransaction: DeleteTransaction(repository),
      );
    });

    tearDown(() {
      bloc.close();
    });

    final testTx = Transaction(
      id: 'tx-1',
      type: 'income',
      amount: 100000,
      category: 'Gaji',
      note: 'Gaji pokok',
      date: DateTime(2026, 10, 1),
    );

    test('initial state is TransactionInitial', () {
      expect(bloc.state, isA<TransactionInitial>());
    });

    test('LoadTransactions emits [TransactionLoading, TransactionLoaded]', () async {
      final expected = [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>().having((s) => s.transactions, 'transactions', isEmpty),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(LoadTransactions());
    });

    test('AddTransactionEvent adds item and emits TransactionLoaded with item', () async {
      final expected = [
        isA<TransactionLoaded>().having((s) => s.transactions.length, 'length', 1),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(AddTransactionEvent(testTx));
    });

    test('UpdateTransactionEvent updates item and emits TransactionLoaded', () async {
      await repository.addTransaction(testTx);

      final updatedTx = testTx.copyWith(amount: 150000, note: 'Gaji dinaikkan');

      final expected = [
        isA<TransactionLoaded>().having(
          (s) => s.transactions.first.amount,
          'amount',
          150000,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(UpdateTransactionEvent(updatedTx));
    });

    test('DeleteTransactionEvent removes item and emits TransactionLoaded with empty list', () async {
      await repository.addTransaction(testTx);

      final expected = [
        isA<TransactionLoaded>().having((s) => s.transactions, 'transactions', isEmpty),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(DeleteTransactionEvent(testTx.id));
    });
  });
}
