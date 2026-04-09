import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
import 'package:cinesmart_app/services/api_service.dart';
import 'signup_screen.dart';
import '../shell/app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void loginUser() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    final message = response["message"] ?? "Login failed";

    if (response["message"] == "Login successful") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AppShell(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Login with your email and password to continue.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Use at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}