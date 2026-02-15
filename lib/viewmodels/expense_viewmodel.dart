import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

class ExpenseViewModel extends ChangeNotifier {
  List<Expense> _expenses = [];
  String? _selectedCategory;
  DateTime? _selectedDate;

  // Getters
  List<Expense> get expenses => _expenses;
  String? get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;

  // Computed properties - total expenses calculation
  double get totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses filtered by category
  List<Expense> get filteredExpenses {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return _expenses;
    }
    return _expenses.where((e) => e.category == _selectedCategory).toList();
  }

  // Get total by category (aggregation)
  Map<String, double> get totalByCategory {
    final Map<String, double> categoryTotals = {};
    
    for (var expense in _expenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    
    return categoryTotals;
  }

  // CRUD Operations with validation

  // Add new expense
  bool addExpense({
    required String title,
    required double amount,
    required String category,
    DateTime? date,
  }) {
    // Validate title
    if (title.trim().isEmpty) {
      throw Exception('Title cannot be empty');
    }

    // Validate amount
    if (amount <= 0) {
      throw Exception('Amount must be greater than zero');
    }

    // Validate category
    if (category.isEmpty) {
      throw Exception('Please select a category');
    }

    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      amount: amount,
      date: date ?? DateTime.now(),
      category: category,
    );

    _expenses.add(newExpense);
    notifyListeners();
    return true;
  }

  // Update existing expense
  bool updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    DateTime? date,
  }) {
    // Validate title
    if (title.trim().isEmpty) {
      throw Exception('Title cannot be empty');
    }

    // Validate amount
    if (amount <= 0) {
      throw Exception('Amount must be greater than zero');
    }

    // Validate category
    if (category.isEmpty) {
      throw Exception('Please select a category');
    }

    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw Exception('Expense not found');
    }

    _expenses[index] = _expenses[index].copyWith(
      title: title.trim(),
      amount: amount,
      date: date ?? _expenses[index].date,
      category: category,
    );

    notifyListeners();
    return true;
  }

  // Delete expense
  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Get expense by id
  Expense? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter methods
  void filterByCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void filterByDate(DateTime? date) {
    _selectedDate = date;
    // Apply date filtering logic here if needed
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedDate = null;
    notifyListeners();
  }

  // Get expenses for a specific month (aggregation example)
  Map<String, double> getMonthlyTotal(int year, int month) {
    final monthlyExpenses = _expenses.where((e) =>
        e.date.year == year && e.date.month == month);
    
    final Map<String, double> categoryTotals = {};
    
    for (var expense in monthlyExpenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    
    return categoryTotals;
  }

  // Get top expense categories
  List<MapEntry<String, double>> get topCategories {
    var sorted = totalByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  // Format currency
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}