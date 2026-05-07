import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usersBox = Hive.box('usersBox');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void register() {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || password.length < 4) {
      showMessage('Use an email and at least 4 password characters');
      return;
    }

    if (usersBox.containsKey(email)) {
      showMessage('Account already exists');
      return;
    }

    final now = DateTime.now().toIso8601String();
    usersBox.put(email, {
      'email': email,
      'password': password,
      'createdAt': now,
      'lastLoginAt': now,
    });
    showMessage('Account created. You can log in now.');
    Navigator.pop(context);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text("Register")),
          ],
        ),
      ),
    );
  }
}
