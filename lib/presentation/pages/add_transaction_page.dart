import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import 'add_edit_transaction_page.dart';

class AddTransactionPage extends StatelessWidget {
  final Transaction? transaction;

  const AddTransactionPage({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    return AddEditTransactionPage(transaction: transaction);
  }
}
