import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/about.dart';
import 'package:project_kelompok/screen/signin.dart';
import 'package:project_kelompok/screen/tiket_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 

import '../main.dart'; 
import '../database/evergreen_db.dart';
import '../model/misi_model.dart';
import '../model/poin_model.dart';
import '../model/user_model.dart';

import 'berita_page.dart';
import 'misi_dart.dart';
import 'poin_page.dart';
import 'settings_page.dart'; 

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
