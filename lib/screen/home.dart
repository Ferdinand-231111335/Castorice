import 'package:flutter/material.dart';
import '../main.dart';

class Home extends StatefulWidget {
  final ThemeChangeCallback toggleTheme;
  const Home({super.key, required this.toggleTheme});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_4),
            onPressed: () {
              widget.toggleTheme(true);
            },
          ),
        ],
      ),
      body: const Center(child: Text('Selamat datang di Home')),
    );
  }
}
