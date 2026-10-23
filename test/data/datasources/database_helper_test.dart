import 'package:flutter_test/flutter_test.dart';
import 'package:myuang/data/models/transaction_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper & TransactionLocalDataSource SQLite CRUD Tests', () {
    late Database db;

    setUp(() async {
      db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE transactions (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                amount REAL NOT NULL,
                category TEXT NOT NULL,
                note TEXT,
                date TEXT NOT NULL
              )
            ''');
          },
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('SQLite insert and query transaction', () async {
      final tx = TransactionModel(
        id: 'test-1',
        type: 'income',
        amount: 250000,
        category: 'Gaji',
        note: 'Bonus',
        date: DateTime(2026, 10, 23, 10, 0),
      );

      await db.insert('transactions', tx.toMap());

      final results = await db.query('transactions');
      expect(results.length, 1);
      final fetched = TransactionModel.fromMap(results.first);
      expect(fetched.id, 'test-1');
      expect(fetched.amount, 250000);
      expect(fetched.type, 'income');
      expect(fetched.category, 'Gaji');
    });

    test('SQLite update transaction', () async {
      final tx = TransactionModel(
        id: 'test-2',
        type: 'expense',
        amount: 50000,
        category: 'Makanan',
        note: 'Sarapan',
        date: DateTime(2026, 10, 23, 8, 0),
      );

      await db.insert('transactions', tx.toMap());

      final updated = TransactionModel(
        id: 'test-2',
        type: 'expense',
        amount: 60000,
        category: 'Makanan',
        note: 'Sarapan + jus',
        date: DateTime(2026, 10, 23, 8, 0),
      );

      await db.update(
        'transactions',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: ['test-2'],
      );

      final results = await db.query('transactions', where: 'id = ?', whereArgs: ['test-2']);
      expect(results.length, 1);
      final fetched = TransactionModel.fromMap(results.first);
      expect(fetched.amount, 60000);
      expect(fetched.note, 'Sarapan + jus');
    });

    test('SQLite delete transaction', () async {
      final tx = TransactionModel(
        id: 'test-3',
        type: 'expense',
        amount: 25000,
        category: 'Transportasi',
        note: 'Parkir',
        date: DateTime(2026, 10, 23, 9, 0),
      );

      await db.insert('transactions', tx.toMap());
      await db.delete('transactions', where: 'id = ?', whereArgs: ['test-3']);

      final results = await db.query('transactions', where: 'id = ?', whereArgs: ['test-3']);
      expect(results, isEmpty);
    });
  });
}
