import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/transactions/transactions_screen.dart';

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  int _index = 0;

  final screens = const [
    DashboardScreen(),
    TransactionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: screens[_index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) {
            setState(() {
              _index = i;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Transactions',
            ),
          ],
        ),
      ),
    );
  }
}