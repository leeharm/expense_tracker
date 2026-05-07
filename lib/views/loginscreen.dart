import 'package:expense_tracker/views/registerscreen.dart';
import 'package:expense_tracker/views/salaryscreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usersBox = Hive.box('usersBox');
  final settingsBox = Hive.box('settingsBox');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final user = usersBox.get(email);

    if (email.isEmpty || password.isEmpty) {
      showMessage('Enter your email and password');
      return;
    }

    if (user == null || user['password'] != password) {
      showMessage('Invalid login details');
      return;
    }

    final userData = Map<String, dynamic>.from(user);
    userData['createdAt'] ??= DateTime.now().toIso8601String();
    userData['lastLoginAt'] = DateTime.now().toIso8601String();
    usersBox.put(email, userData);
    settingsBox.put('currentUser', email);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SalaryScreen(userEmail: email)),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
              ElevatedButton(onPressed: login, child: const Text("Login")),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
