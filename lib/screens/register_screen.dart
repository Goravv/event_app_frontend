import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/user.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirm = false;
  String? errorMessage;

  Future<void> register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.6:5000/api/user/register"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final user = AppUser.fromJson(data['user']); 

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(userFromLogin: user),
          ),
        );
      } else {
        final data = json.decode(response.body);
        setState(() => errorMessage = data['error'] ?? "Registration failed");
      }
    } catch (e) {
      setState(() => errorMessage = "Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration buildInputDecoration(String label,
      {bool isPassword = false, bool isConfirm = false}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      suffixIcon: isPassword || isConfirm
          ? IconButton(
              icon: Icon(
                (isPassword ? showPassword : showConfirm)
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  if (isPassword) {
                    showPassword = !showPassword;
                  } else {
                    showConfirm = !showConfirm;
                  }
                });
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Create an Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: usernameController,
                decoration: buildInputDecoration("Username"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                decoration: buildInputDecoration("Email"),
                validator: (value) =>
                    value == null || !value.contains('@') ? "Invalid email" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: buildInputDecoration("Password", isPassword: true),
                validator: (value) =>
                    value == null || value.length < 6 ? "Min 6 characters" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: confirmController,
                obscureText: !showConfirm,
                decoration:
                    buildInputDecoration("Confirm Password", isConfirm: true),
                validator: (value) =>
                    value != passwordController.text ? "Passwords do not match" : null,
              ),
              const SizedBox(height: 24),

              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
