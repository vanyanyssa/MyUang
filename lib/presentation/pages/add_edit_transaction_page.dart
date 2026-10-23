import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/categories.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

class AddEditTransactionPage extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionPage({super.key, this.transaction});

  bool get isEditing => transaction != null;

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _type;
  late String _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _type = tx.type;
      _category = tx.category;
      _date = tx.date;
      _amountController = TextEditingController(
        text: tx.amount.truncateToDouble() == tx.amount
            ? tx.amount.toInt().toString()
            : tx.amount.toString(),
      );
      _noteController = TextEditingController(text: tx.note);
    } else {
      _type = 'expense';
      _category = AppCategories.getExpenseCategoryNames().first;
      _date = DateTime.now();
      _amountController = TextEditingController();
      _noteController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _currentCategories {
    return _type == 'income'
        ? AppCategories.getIncomeCategoryNames()
        : AppCategories.getExpenseCategoryNames();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih Tanggal Transaksi',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (selectedDate != null) {
      setState(() {
        // Retain current hour/minute if needed or set to selected day
        _date = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          _date.hour,
          _date.minute,
        );
      });
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rawAmountText = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll('Rp', '')
        .trim();

    final amount = double.tryParse(rawAmountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal harus lebih besar dari 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final note = _noteController.text.trim();

    if (widget.isEditing) {
      final updated = widget.transaction!.copyWith(
        type: _type,
        amount: amount,
        category: _category,
        note: note,
        date: _date,
      );
      context.read<TransactionBloc>().add(UpdateTransactionEvent(updated));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final newTransaction = Transaction(
        id: const Uuid().v4(),
        type: _type,
        amount: amount,
        category: _category,
        note: note,
        date: _date,
      );
      context.read<TransactionBloc>().add(AddTransactionEvent(newTransaction));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == 'income';
    final categories = _currentCategories;

    // Ensure selected category is valid for current type
    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Ubah Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Transaction Type Selector
            const Text(
              'Jenis Transaksi',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'income',
                  label: Text('Pemasukan'),
                  icon: Icon(Icons.arrow_downward, color: Colors.green),
                ),
                ButtonSegment(
                  value: 'expense',
                  label: Text('Pengeluaran'),
                  icon: Icon(Icons.arrow_upward, color: Colors.red),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _type = newSelection.first;
                  final available = _currentCategories;
                  if (!available.contains(_category)) {
                    _category = available.first;
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Nominal Input
            const Text(
              'Nominal (Rp)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
                prefixIcon: Icon(
                  Icons.monetization_on_outlined,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nominal wajib diisi';
                }
                final cleaned = value
                    .replaceAll('.', '')
                    .replaceAll(',', '.')
                    .replaceAll('Rp', '')
                    .trim();
                final val = double.tryParse(cleaned);
                if (val == null) {
                  return 'Format nominal tidak valid';
                }
                if (val <= 0) {
                  return 'Nominal harus lebih besar dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Category Selector
            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories.map((cat) {
                final catInfo = AppCategories.getCategoryInfo(cat, _type);
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: catInfo.color.withValues(alpha: 0.2),
                        child: Icon(catInfo.icon, size: 14, color: catInfo.color),
                      ),
                      const SizedBox(width: 10),
                      Text(cat),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _category = val;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Date Picker
            const Text(
              'Tanggal Transaksi',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: Colors.blueGrey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormatter.formatFull(_date),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Note / Description (Optional)
            const Text(
              'Catatan / Deskripsi (Opsional)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Contoh: Makan siang bersama teman',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveTransaction,
                icon: Icon(widget.isEditing ? Icons.check_circle_outline : Icons.save_outlined),
                label: Text(
                  widget.isEditing ? 'Perbarui Transaksi' : 'Simpan Transaksi',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
