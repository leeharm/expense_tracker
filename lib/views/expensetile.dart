import 'package:flutter/material.dart';

class ExpenseTile extends StatelessWidget {
  final String title;
  final String amount;
  final String date;

  const ExpenseTile({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.money, color: Colors.white),
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }
}
