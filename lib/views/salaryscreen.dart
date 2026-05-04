import 'package:expense_tracker/views/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SalaryScreen extends StatefulWidget {
  final String userEmail;

  const SalaryScreen({super.key, required this.userEmail});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final controller = TextEditingController();
  final settingsBox = Hive.box('settingsBox');

  @override
  void initState() {
    super.initState();
    final savedSalary = settingsBox.get('salary:${widget.userEmail}');
    if (savedSalary != null) {
      controller.text = (savedSalary as num).toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void goNext() {
    final salary = double.tryParse(controller.text) ?? 0;

    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid monthly salary')),
      );
      return;
    }

    settingsBox.put('salary:${widget.userEmail}', salary);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(salary: salary, userEmail: widget.userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Salary")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Your salary will be split using the 50/30/20 budget rule.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monthly Salary",
                prefixText: 'KES ',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: goNext, child: const Text("Continue")),
          ],
        ),
      ),
    );
  }
}
