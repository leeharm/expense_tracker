class Expense {
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String userEmail;

  Expense({
    required this.title,
    required this.amount,
    required this.category,
    DateTime? date,
    this.userEmail = '',
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'userEmail': userEmail,
  };

  factory Expense.fromMap(Map map) => Expense(
    title: map['title'] ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    category: map['category'] ?? 'Needs',
    date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
    userEmail: map['userEmail'] ?? '',
  );
}
