import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/firestore_parsing.dart';
import 'expense_category.dart';

/// A single spending entry stored at users/{uid}/expenses/{id}.
class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
    this.note = '',
    this.isSample = false,
  });

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    final title = readString(map['title']).trim();
    return Expense(
      id: id,
      title: title.isEmpty ? 'Untitled' : title,
      amount: readDouble(map['amount']),
      category: ExpenseCategory.fromLabel(readString(map['category'])),
      date: readDate(map['date']),
      note: readString(map['note']).trim(),
      createdAt: readDate(map['createdAt']),
      isSample: map['isSample'] == true,
    );
  }

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  /// True for the demo expenses added when an account is created.
  final bool isSample;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category.label,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'isSample': isSample,
    };
  }

  Expense copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      isSample: isSample,
    );
  }
}
