class Expense {
  final String id;
  String title;
  double amount;
  DateTime date;
  String category;

  // Predefined categories with their icons and colors
  static const List<String> categories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Other'
  ];

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  // Create a copy of the expense with updated fields
  Expense copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? category,
  }) {
    return Expense(
      id: this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  // Convert Expense to Map for storage (if needed for future extensions)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  // Create Expense from Map (if needed for future extensions)
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: json['category'],
    );
  }
}