// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense app renders', (WidgetTester tester) async {
    final tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    await Hive.openBox('usersBox');
    await Hive.openBox('settingsBox');
    await Hive.openBox('expensesBox');
    await Hive.openBox('monthlyBox');

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExpenseApp());

    expect(find.text('Login'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });
}
