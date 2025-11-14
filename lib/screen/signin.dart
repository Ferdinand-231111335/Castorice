import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  String handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return "Format email tidak valid.";
      case "user-disabled":
        return "Akun ini telah dinonaktifkan.";
      case "user-not-found":
        return "Pengguna tidak ditemukan.";
      case "wrong-password":
        return "Password salah.";
      case "email-already-in-use":
        return "Email sudah digunakan.";
      case "weak-password":
        return "Password terlalu lemah.";
      default:
        return "Terjadi kesalahan: ${e.message}";
    }
  }

  @override
  void initState() {
    super.initState();

    analytics.logEvent(
      name: "sign_in_page_opened",
      parameters: {"page": "SignIn"},
    );
  }

  Future<void> _login() async {
    analytics.logEvent(
      name: "sign_in_attempt",
      parameters: {
        "email_length": emailController.text.trim().length,
      },
    );

    try {
      final user = await db.getUserByEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('userId', user.id!);
        await prefs.setString('username', user.username);
        await prefs.setString('email', user.email);

        if (user.profilePicture != null) {
          await prefs.setString('profilePicture', user.profilePicture!);
        } else {
          await prefs.remove('profilePicture');
        }

        analytics.logEvent(
          name: "sign_in_success",
          parameters: {
            "user_id": user.id.toString(),
            "email": user.email,
          },
        );

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => Home(toggleTheme: widget.toggleTheme)),
            (route) => false,
          );
        }
      } else {
        analytics.logEvent(
          name: "sign_in_failed",
          parameters: {"email": emailController.text.trim()},
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email atau password salah")),
        );
      }

    } on FirebaseAuthException catch (e) {
      final msg = handleFirebaseAuthException(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

      analytics.logEvent(
        name: "sign_in_firebase_error",
        parameters: {"error": e.code},
      );
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
