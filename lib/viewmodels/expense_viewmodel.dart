import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ExpenseViewModel extends ChangeNotifier {
  List<Expense> _expenses = [];
  String? _selectedCategory;
  DateTime? _selectedDate;
  
  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection reference
  late final CollectionReference<Map<String, dynamic>> _expensesCollection;
  
  // Loading state
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Expense> get expenses => _expenses;
  String? get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor
  ExpenseViewModel() {
    _expensesCollection = _firestore.collection('expenses');
    loadExpenses(); // Load expenses when ViewModel is created
  }

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

  // Load all expenses from Firebase
  Future<void> loadExpenses() async {
    _setLoading(true);
    _clearError();
    
    try {
      final querySnapshot = await _expensesCollection
          .orderBy('date', descending: true)
          .get();
      
      _expenses = querySnapshot.docs
          .map((doc) => Expense.fromFirestore(doc))
          .toList();
      
      notifyListeners();
      print('Loaded ${_expenses.length} expenses from Firebase');
    } catch (e) {
      _setError('Failed to load expenses: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // CRUD Operations with Firebase

  // Add new expense
  Future<bool> addExpense({
    required String title,
    required double amount,
    required String category,
    DateTime? date,
  }) async {
    // Validate inputs
    try {
      _validateExpenseInputs(title, amount, category);
    } catch (e) {
      _setError(e.toString());
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final newExpense = Expense(
        id: '', // Will be set by Firebase
        title: title.trim(),
        amount: amount,
        date: date ?? DateTime.now(),
        category: category,
      );

      // Add to Firebase
      final docRef = await _expensesCollection.add(newExpense.toFirestore());
      
      // Update local list with the generated ID
      final addedExpense = newExpense.copyWith(id: docRef.id);
      _expenses.insert(0, addedExpense); // Add at beginning for newest first
      
      notifyListeners();
      print("Expenses Successfully Added: ${addedExpense.title} - ${addedExpense.amount}");
      return true;
    } catch (e) {
      _setError('Failed to add expense: ${e.toString()}');
      print("Expenses Not Successfully Added!: ${e.toString()}");
      return false;
    } finally {
      _setLoading(false);
      
    }
  }

  // Update existing expense
  Future<bool> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    DateTime? date,
  }) async {
    // Validate inputs
    try {
      _validateExpenseInputs(title, amount, category);
    } catch (e) {
      _setError(e.toString());
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index == -1) {
        throw Exception('Expense not found');
      }

      final updatedExpense = _expenses[index].copyWith(
        title: title.trim(),
        amount: amount,
        date: date ?? _expenses[index].date,
        category: category,
      );

      // Update in Firebase
      await _expensesCollection.doc(id).update(updatedExpense.toFirestore());
      
      // Update local list
      _expenses[index] = updatedExpense;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update expense: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Delete from Firebase
      await _expensesCollection.doc(id).delete();
      
      // Remove from local list
      _expenses.removeWhere((e) => e.id == id);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete expense: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
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

  // Private helper methods

  void _validateExpenseInputs(String title, double amount, String category) {
    if (title.trim().isEmpty) {
      throw Exception('Title cannot be empty');
    }
    if (amount <= 0) {
      throw Exception('Amount must be greater than zero');
    }
    if (category.isEmpty) {
      throw Exception('Please select a category');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Real-time updates (optional)
  void subscribeToExpenses() {
    _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _expenses = snapshot.docs
          .map((doc) => Expense.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }
}