import 'package:expense_tracker/views/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AssistantScreen extends StatefulWidget {
  final String userEmail;
  final double salary;

  const AssistantScreen({
    super.key,
    required this.userEmail,
    required this.salary,
  });

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final controller = TextEditingController();
  final expenseBox = Hive.box('expensesBox');
  final usersBox = Hive.box('usersBox');
  final messages = <_AssistantMessage>[];

  @override
  void initState() {
    super.initState();
    messages.add(
      _AssistantMessage(
        text:
            'Ask me how to use the app, where to add expenses, or request an account summary.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Expense> get expenses {
    return expenseBox.values
        .whereType<Map>()
        .map((item) => Expense.fromMap(Map<String, dynamic>.from(item)))
        .where((expense) => expense.userEmail == widget.userEmail)
        .toList();
  }

  DateTime get accountCreatedAt {
    final user = usersBox.get(widget.userEmail);
    if (user is Map) {
      final createdAt = DateTime.tryParse(user['createdAt']?.toString() ?? '');
      if (createdAt != null) return createdAt;
    }
    if (expenses.isEmpty) return DateTime.now();
    final sorted = [...expenses]..sort((a, b) => a.date.compareTo(b.date));
    return sorted.first.date;
  }

  String get currentMonth => DateTime.now().toString().substring(0, 7);

  List<Expense> get currentMonthExpenses {
    return expenses.where((expense) {
      final month =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      return month == currentMonth;
    }).toList();
  }

  void send() {
    final question = controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      messages.add(_AssistantMessage(text: question, isUser: true));
      messages.add(_AssistantMessage(text: answer(question), isUser: false));
      controller.clear();
    });
  }

  String answer(String question) {
    final text = question.toLowerCase();

    if (text.contains('summary') ||
        text.contains('account') ||
        text.contains('report')) {
      return accountSummary();
    }

    if (text.contains('add') || text.contains('expense')) {
      return 'To add an expense, go back to the dashboard and tap the + Expense button. Enter a title, amount, and category, then save it.';
    }

    if (text.contains('salary') || text.contains('50') || text.contains('30')) {
      return 'The salary screen saves your monthly salary. The dashboard splits it into Needs 50%, Wants 30%, and Savings 20%.';
    }

    if (text.contains('saving') || text.contains('savings')) {
      return 'Savings progress is calculated from expenses saved under the Savings category. The line chart shows your saved amount month by month.';
    }

    if (text.contains('chart') || text.contains('graph')) {
      return 'Pie charts show salary split and category totals. The line chart shows savings progress over months.';
    }

    if (text.contains('data') || text.contains('store')) {
      return 'Your account, salary, expenses, and monthly summaries are stored locally using Hive. Each record is linked to your email account.';
    }

    if (text.contains('login') || text.contains('register')) {
      return 'Create an account on the register screen, then log in with the same email and password. Your tracking starts from the account creation date.';
    }

    return 'I can help with app navigation, adding expenses, salary split, charts, stored data, savings progress, and account summaries. Try asking: "Give me my account summary."';
  }

  String accountSummary() {
    final allExpenses = expenses;
    final monthExpenses = currentMonthExpenses;
    final totalSpent = allExpenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final monthSpent = monthExpenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final monthSaved = monthExpenses
        .where((expense) => expense.category == 'Savings')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final savingsGoal = widget.salary * 0.20;
    final createdAt = accountCreatedAt;
    final trackingDays = DateTime.now().difference(createdAt).inDays + 1;
    final topCategory = topCategoryFor(monthExpenses);

    return [
      'Account summary',
      'Tracking started: ${formatDate(createdAt)} ($trackingDays day(s))',
      'Monthly salary: ${money(widget.salary)}',
      'This month spent: ${money(monthSpent)}',
      'This month saved: ${money(monthSaved)} of ${money(savingsGoal)} goal',
      'All-time tracked expenses: ${money(totalSpent)} across ${allExpenses.length} record(s)',
      'Top current-month category: $topCategory',
    ].join('\n');
  }

  String topCategoryFor(List<Expense> source) {
    if (source.isEmpty) return 'No expenses yet';
    final totals = <String, double>{};
    for (final expense in source) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return '${entries.first.key} (${money(entries.first.value)})';
  }

  String money(double value) => 'KES ${value.toStringAsFixed(0)}';

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 340),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Colors.green.shade700
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask about this app',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantMessage {
  final String text;
  final bool isUser;

  const _AssistantMessage({required this.text, required this.isUser});
}
