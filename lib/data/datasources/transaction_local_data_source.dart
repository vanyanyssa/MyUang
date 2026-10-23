import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';
import 'database_helper.dart';

class TransactionLocalDataSource {
  final DatabaseHelper databaseHelper;

  TransactionLocalDataSource({required this.databaseHelper});

  Future<List<TransactionModel>> getTransactions() async {
    final Database db = await databaseHelper.database;

    final result = await db.query('transactions', orderBy: 'date DESC');

    return result.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final Database db = await databaseHelper.database;

    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final Database db = await databaseHelper.database;

    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final Database db = await databaseHelper.database;

    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
