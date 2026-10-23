class Transaction {
  final String id;
  final String type; // 'income' or 'expense'
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          amount == other.amount &&
          category == other.category &&
          note == other.note &&
          date == other.date;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      note.hashCode ^
      date.hashCode;

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, category: $category, date: $date)';
  }
}
