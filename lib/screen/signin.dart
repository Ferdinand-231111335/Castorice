import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/evergreen_db.dart';
import 'home.dart';
import 'signup.dart';
import '../main.dart';

class SignIn extends StatefulWidget {
  final ThemeChangeCallback toggleTheme;
  const SignIn({super.key, required this.toggleTheme}); 

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final EvergreenDb db = EvergreenDb();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

Future<void> _login() async {
  final user = await db.getUserByEmail(
    emailController.text.trim(),
    passwordController.text.trim(),
  );

  if (user != null) {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', user.id!); // SIMPAN USER ID DI SINI
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    if (user.profilePicture != null) {
      await prefs.setString('profilePicture', user.profilePicture!); // Simpan path foto profil
    } else {
      await prefs.remove('profilePicture');
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Home(toggleTheme: widget.toggleTheme)),
        (route) => false,
      );
    }
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email atau password salah")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Sign In"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUp()),
                );
              },
              child: const Text("Belum punya akun? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}