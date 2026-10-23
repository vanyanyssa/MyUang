import 'package:flutter_test/flutter_test.dart';
import 'package:myuang/data/models/transaction_model.dart';

void main() {
  group('TransactionModel & Transaction Entity Tests', () {
    final now = DateTime(2026, 10, 23, 12, 0, 0);

    final model = TransactionModel(
      id: 'tx-123',
      type: 'expense',
      amount: 75000.0,
      category: 'Makanan',
      note: 'Makan siang enak',
      date: now,
    );

    test('should correctly convert to and from Map for SQLite', () {
      final map = model.toMap();

      expect(map['id'], 'tx-123');
      expect(map['type'], 'expense');
      expect(map['amount'], 75000.0);
      expect(map['category'], 'Makanan');
      expect(map['note'], 'Makan siang enak');
      expect(map['date'], now.toIso8601String());

      final fromMapModel = TransactionModel.fromMap(map);

      expect(fromMapModel.id, model.id);
      expect(fromMapModel.type, model.type);
      expect(fromMapModel.amount, model.amount);
      expect(fromMapModel.category, model.category);
      expect(fromMapModel.note, model.note);
      expect(fromMapModel.date, model.date);
    });

    test('helper getters isIncome and isExpense work correctly', () {
      expect(model.isExpense, isTrue);
      expect(model.isIncome, isFalse);

      final incomeTx = model.copyWith(type: 'income');
      expect(incomeTx.isIncome, isTrue);
      expect(incomeTx.isExpense, isFalse);
    });

    test('copyWith produces exact expected updates', () {
      final updated = model.copyWith(
        amount: 80000.0,
        note: 'Update note',
      );

      expect(updated.id, model.id);
      expect(updated.amount, 80000.0);
      expect(updated.note, 'Update note');
      expect(updated.category, model.category);
    });
  });
}
