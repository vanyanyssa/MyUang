import 'package:flutter/material.dart';

class TransactionCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String type; // 'income' or 'expense'

  const TransactionCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class AppCategories {
  static const List<TransactionCategory> incomeCategories = [
    TransactionCategory(
      name: 'Gaji',
      icon: Icons.payments_outlined,
      color: Color(0xFF2E7D32),
      type: 'income',
    ),
    TransactionCategory(
      name: 'Uang Saku',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF1565C0),
      type: 'income',
    ),
    TransactionCategory(
      name: 'Bisnis',
      icon: Icons.store_outlined,
      color: Color(0xFF00838F),
      type: 'income',
    ),
    TransactionCategory(
      name: 'Hadiah',
      icon: Icons.card_giftcard_outlined,
      color: Color(0xFF6A1B9A),
      type: 'income',
    ),
    TransactionCategory(
      name: 'Lainnya',
      icon: Icons.more_horiz_outlined,
      color: Color(0xFF455A64),
      type: 'income',
    ),
  ];

  static const List<TransactionCategory> expenseCategories = [
    TransactionCategory(
      name: 'Makanan',
      icon: Icons.restaurant_outlined,
      color: Color(0xFFE65100),
      type: 'expense',
    ),
    TransactionCategory(
      name: 'Transportasi',
      icon: Icons.directions_car_outlined,
      color: Color(0xFF0277BD),
      type: 'expense',
    ),
    TransactionCategory(
      name: 'Pendidikan',
      icon: Icons.school_outlined,
      color: Color(0xFF283593),
      type: 'expense',
    ),
    TransactionCategory(
      name: 'Belanja',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFFC2185B),
      type: 'expense',
    ),
    TransactionCategory(
      name: 'Hiburan',
      icon: Icons.movie_outlined,
      color: Color(0xFF7B1FA2),
      type: 'expense',
    ),
    TransactionCategory(
      name: 'Tagihan',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFD84315),
      type: 'expense',
    ),
    TransactionCategory(
      name: 'Kesehatan',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFF00897B),
      type: 'expense',
    ),
    TransactionCategory(
      name: 'Lainnya',
      icon: Icons.more_horiz_outlined,
      color: Color(0xFF546E7A),
      type: 'expense',
    ),
  ];

  static List<String> getIncomeCategoryNames() {
    return incomeCategories.map((c) => c.name).toList();
  }

  static List<String> getExpenseCategoryNames() {
    return expenseCategories.map((c) => c.name).toList();
  }

  static TransactionCategory getCategoryInfo(String name, String type) {
    final list = type == 'income' ? incomeCategories : expenseCategories;
    return list.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => TransactionCategory(
        name: name,
        icon: Icons.category_outlined,
        color: const Color(0xFF607D8B),
        type: type,
      ),
    );
  }

  static Color getCategoryColor(String name) {
    for (final c in [...expenseCategories, ...incomeCategories]) {
      if (c.name.toLowerCase() == name.toLowerCase()) {
        return c.color;
      }
    }
    return const Color(0xFF607D8B);
  }
}
