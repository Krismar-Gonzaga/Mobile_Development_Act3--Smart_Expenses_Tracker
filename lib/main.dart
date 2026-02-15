import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'views/expense_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseViewModel(),
      child: MaterialApp(
        title: 'Smart Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: _buildMatchaTheme(),
        home: const ExpenseListScreen(),
      ),
    );
  }

  ThemeData _buildMatchaTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: const Color(0xFF2C5F2D), // Dark matcha
      scaffoldBackgroundColor: const Color(0xFFF5F7E9), // Light cream
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF2C5F2D),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF97B89A), // Light matcha
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white.withOpacity(0.95),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF97B89A), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C5F2D), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        labelStyle: const TextStyle(color: Color(0xFF2C5F2D)),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    );
  }
}