import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/evergreen_db.dart';
import '../model/user_model.dart' as local;
import 'home.dart';
import 'signup.dart';
import '../main.dart';

class SignIn extends StatefulWidget {
  final ThemeChangeCallback toggleTheme;
  const SignIn({
    super.key,
    required this.toggleTheme,
    required void Function(Locale locale) changeLocale,
  });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final EvergreenDb db = EvergreenDb();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    analytics.logEvent(
      name: "sign_in_attempt",
      parameters: {"email_length": email.length},
    );

    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw Exception("Data user tidak ditemukan di Firestore");
      }

      final data = doc.data()!;

      final localUser = local.User(
        username: data['username'],
        email: data['email'],
        password: '',
      );

      await db.insertOrReplaceUser(localUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uid', uid);
      await prefs.setString('username', data['username']);
      await prefs.setString('email', data['email']);

      analytics.logEvent(
        name: "sign_in_success",
        parameters: {"uid": uid, "email": data['email']},
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => Home(toggleTheme: widget.toggleTheme),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      final msg = handleFirebaseAuthException(e);

      analytics.logEvent(name: "sign_in_failed", parameters: {"error": e.code});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      analytics.logEvent(
        name: "sign_in_failed_unknown",
        parameters: {"error": e.toString()},
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Halaman Sign In',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
          backgroundColor: Colors.green,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Semantics(
                label: 'Input Email',
                hint: 'Masukkan alamat email',
                textField: true,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),

              Semantics(
                label: 'Input Password',
                hint: 'Masukkan kata sandi',
                textField: true,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ),

              const SizedBox(height: 20),

              Semantics(
                label: 'Sign In Button',
                button: true,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Sign In'),
                ),
              ),

              Semantics(
                label: 'Belum punya akun? Sign Up',
                hint: 'Ketuk dua kali untuk membuat akun baru',
                button: true,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUp()),
                    );
                  },
                  child: const Text('Belum punya akun? Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
