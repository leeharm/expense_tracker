import 'package:expense_tracker/views/addexpensescreen.dart';
import 'package:expense_tracker/views/expensetile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense Tracker"), centerTitle: true),
      body: Column(
        children: [
          // Balance Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            width: double.infinity,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Balance", style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text(
                  "KES 12,500",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Expense List
          Expanded(
            child: ListView(
              children: const [
                ExpenseTile(title: "Lunch", amount: "- KES 500", date: "Today"),
                ExpenseTile(
                  title: "Transport",
                  amount: "- KES 300",
                  date: "Yesterday",
                ),
                ExpenseTile(
                  title: "Airtime",
                  amount: "- KES 200",
                  date: "2 days ago",
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
      ),
    );
  }
}
