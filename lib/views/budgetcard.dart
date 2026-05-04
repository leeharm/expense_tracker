import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const BudgetCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color),
        title: Text(title),
        trailing: Text(
          "KES $amount",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
