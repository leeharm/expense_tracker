import 'package:expense_tracker/views/model/expense.dart';
import 'package:expense_tracker/views/expensescreen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  final double salary;
  final String userEmail;

  const HomeScreen({super.key, required this.salary, required this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final expenseBox = Hive.box('expensesBox');
  final monthlyBox = Hive.box('monthlyBox');

  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() {
    final data = expenseBox.values.toList();
    expenses = data
        .map((e) => Expense.fromMap(Map<String, dynamic>.from(e)))
        .where((expense) => expense.userEmail == widget.userEmail)
        .toList();
    saveMonthlyData();
    setState(() {});
  }

  String get currentMonth => DateTime.now().toString().substring(0, 7);

  double get totalSpent => expenses.fold(0, (a, b) => a + b.amount);
  double get currentMonthSpent =>
      currentMonthExpenses.fold(0, (total, expense) => total + expense.amount);
  double get currentMonthSaved => currentMonthExpenses
      .where((expense) => expense.category == 'Savings')
      .fold(0, (total, expense) => total + expense.amount);
  double get remaining => widget.salary - totalSpent;
  double get currentMonthRemaining => widget.salary - currentMonthSpent;
  double get spendRate =>
      widget.salary <= 0 ? 0 : (currentMonthSpent / widget.salary);

  double get needsBudget => widget.salary * 0.50;
  double get wantsBudget => widget.salary * 0.30;
  double get savingsBudget => widget.salary * 0.20;
  double get savingsRate =>
      savingsBudget <= 0 ? 0 : (currentMonthSaved / savingsBudget);

  List<Expense> get currentMonthExpenses {
    return expenses.where((expense) {
      final key =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      return key == currentMonth;
    }).toList();
  }

  Map<String, double> get categoryTotals {
    final totals = <String, double>{};
    for (final expense in currentMonthExpenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }

  Map<String, double> get monthlyTotals {
    final totals = <String, double>{};
    for (final expense in expenses) {
      final key =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      totals.update(
        key,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }

  List<MapEntry<String, double>> get monthlySavingsEntries {
    final saved = <String, double>{};

    for (final value in monthlyBox.values) {
      if (value is Map) {
        final item = Map<String, dynamic>.from(value);
        if (item['userEmail'] == widget.userEmail) {
          saved[item['month']] = (item['saved'] as num?)?.toDouble() ?? 0;
        }
      }
    }

    for (final expense in expenses.where(
      (item) => item.category == 'Savings',
    )) {
      final month =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      saved.update(
        month,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    saved.update(
      currentMonth,
      (_) => currentMonthSaved,
      ifAbsent: () => currentMonthSaved,
    );

    final entries = saved.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  Map<String, double> get savingsComparison {
    return {
      'Saved': currentMonthSaved,
      'To Goal': (savingsBudget - currentMonthSaved).clamp(0, savingsBudget),
    };
  }

  Color savingsColor(String label) {
    switch (label) {
      case 'Saved':
        return const Color(0xFF1976D2);
      case 'To Goal':
        return const Color(0xFFBDBDBD);
      default:
        return Colors.grey;
    }
  }

  void saveMonthlyData() {
    monthlyBox.put('${widget.userEmail}:$currentMonth', {
      'userEmail': widget.userEmail,
      'month': currentMonth,
      'salary': widget.salary,
      'spent': currentMonthSpent,
      'saved': currentMonthSaved,
      'remaining': currentMonthRemaining,
      'needsBudget': needsBudget,
      'wantsBudget': wantsBudget,
      'savingsBudget': savingsBudget,
    });
  }

  void addExpense(Expense expense) {
    final userExpense = Expense(
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      userEmail: widget.userEmail,
    );
    expenseBox.add(userExpense.toMap());
    expenses.add(userExpense);
    saveMonthlyData();
    setState(() {});
  }

  Future<void> openAddExpense() async {
    final expense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );

    if (expense != null) {
      addExpense(expense);
    }
  }

  String money(double value) => 'KES ${value.toStringAsFixed(0)}';

  Color categoryColor(String category) {
    switch (category) {
      case 'Needs':
        return const Color(0xFF2E7D32);
      case 'Wants':
        return const Color(0xFFFF9800);
      case 'Savings':
        return const Color(0xFF1976D2);
      case 'Bills':
        return Colors.redAccent;
      case 'Transport':
        return Colors.purple;
      case 'Food':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedExpenses = [...currentMonthExpenses]
      ..sort((a, b) => b.date.compareTo(a.date));
    final monthEntries = monthlySavingsEntries;
    final ruleTotals = {
      'Needs 50%': needsBudget,
      'Wants 30%': wantsBudget,
      'Savings 20%': savingsBudget,
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Expense Tracker")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddExpense,
        icon: const Icon(Icons.add),
        label: const Text('Expense'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadExpenses(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryHeader(
              salary: money(widget.salary),
              spent: money(currentMonthSpent),
              remaining: money(currentMonthRemaining),
              spendRate: spendRate.clamp(0, 1),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              title: '50/30/20 Salary Split',
              action: money(widget.salary),
            ),
            const SizedBox(height: 8),
            _CategoryChart(
              totals: ruleTotals,
              colorFor: (category) {
                if (category.startsWith('Needs')) return categoryColor('Needs');
                if (category.startsWith('Wants')) return categoryColor('Wants');
                return categoryColor('Savings');
              },
              money: money,
            ),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Actual Spending Split',
              action: '${(spendRate * 100).toStringAsFixed(0)}% used',
            ),
            const SizedBox(height: 8),
            if (categoryTotals.isEmpty)
              const _EmptyState()
            else
              _CategoryChart(
                totals: categoryTotals,
                colorFor: categoryColor,
                money: money,
              ),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Savings Goal',
              action: '${(savingsRate * 100).toStringAsFixed(0)}% reached',
            ),
            const SizedBox(height: 8),
            _CategoryChart(
              totals: savingsComparison,
              colorFor: savingsColor,
              money: money,
            ),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Savings Progress',
              action: '${monthEntries.length} month(s)',
            ),
            const SizedBox(height: 8),
            _MonthlyTrend(entries: monthEntries),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Recent Activity'),
            const SizedBox(height: 8),
            if (sortedExpenses.isEmpty)
              const _EmptyState()
            else
              ...sortedExpenses
                  .take(8)
                  .map(
                    (expense) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: categoryColor(expense.category),
                          child: const Icon(
                            Icons.payments,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(expense.title),
                        subtitle: Text(expense.category),
                        trailing: Text(
                          money(expense.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final String salary;
  final String spent;
  final String remaining;
  final double spendRate;

  const _SummaryHeader({
    required this.salary,
    required this.spent,
    required this.remaining,
    required this.spendRate,
  });

  @override
  Widget build(BuildContext context) {
    final isOverBudget = spendRate >= 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12372A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Month',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            remaining,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isOverBudget ? 'Over budget' : 'left after tracked expenses',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: spendRate,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.redAccent : Colors.lightGreenAccent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Metric(label: 'Income', value: salary),
              ),
              Expanded(
                child: _Metric(label: 'Spent', value: spent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;

  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (action != null)
          Text(action!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final Map<String, double> totals;
  final Color Function(String category) colorFor;
  final String Function(double amount) money;

  const _CategoryChart({
    required this.totals,
    required this.colorFor,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    final total = totals.values.fold<double>(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 190,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 42,
                  sections: totals.entries.map((entry) {
                    final percent = total == 0 ? 0 : entry.value / total * 100;
                    return PieChartSectionData(
                      color: colorFor(entry.key),
                      value: entry.value,
                      title: '${percent.toStringAsFixed(0)}%',
                      radius: 58,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...totals.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colorFor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key)),
                    Text(money(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyTrend extends StatelessWidget {
  final List<MapEntry<String, double>> entries;

  const _MonthlyTrend({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _EmptyState();
    }

    final maxY = entries
        .map((entry) => entry.value)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              maxY: maxY == 0 ? 100 : maxY * 1.2,
              minY: 0,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    const FlLine(color: Color(0xFFE0E0E0), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(entries[index].key.substring(5)),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < entries.length; i++)
                      FlSpot(i.toDouble(), entries[i].value),
                  ],
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 4,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: const [
            Icon(Icons.insights_outlined),
            SizedBox(width: 10),
            Expanded(child: Text('Add expenses to unlock your analytics.')),
          ],
        ),
      ),
    );
  }
}
