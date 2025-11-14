import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../database/evergreen_db.dart';
import '../model/user_model.dart' as local;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final EvergreenDb db = EvergreenDb(); // OPSIONAL

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // HANDLE ERROR FIREBASE
  String firebaseErrorMsg(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return "Format email tidak valid.";
      case "email-already-in-use":
        return "Email sudah terdaftar.";
      case "weak-password":
        return "Password terlalu lemah (min 6 karakter).";
      case "operation-not-allowed":
        return "Firebase Auth belum diaktifkan.";
      default:
        return "Terjadi kesalahan: ${e.message}";
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(username);

      await db.insertUser(
        local.User(username: username, email: email, password: password),
      );

      await analytics.logEvent(
        name: "sign_up_success",
        parameters: {
          "email": email,
          "username": username,
          "user_id": credential.user!.uid,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil!")),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      final msg = firebaseErrorMsg(e);

      await analytics.logEvent(
        name: "sign_up_failed",
        parameters: {
          "error": e.code,
          "email": email,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

    } catch (e) {
      await analytics.logEvent(
        name: "sign_up_failed_unknown",
        parameters: {"error": e.toString()},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (value) =>
                    value!.isEmpty ? "Masukkan username" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value!.isEmpty) return "Masukkan email";
                  if (!value.contains("@")) return "Format email tidak valid";
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (value) {
                  if (value!.isEmpty) return "Masukkan password";
                  if (value.length < 6) return "Password minimal 6 karakter";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Sign Up"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
