import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/ticket_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../database/evergreen_db.dart';
import 'signin.dart';
import '../main.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String currentEmail;
  final String? currentProfilePicturePath;
  final int? userId;
  final Function(String, String, String?) onProfileUpdated;

  const EditProfilePage({
    super.key,
    required this.currentUsername,
    required this.currentEmail,
    required this.currentProfilePicturePath,
    required this.userId,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  String? profilePicturePath;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.currentUsername);
    emailController = TextEditingController(text: widget.currentEmail);
    profilePicturePath = widget.currentProfilePicturePath;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                widget.onProfileUpdated(
                  usernameController.text,
                  emailController.text,
                  profilePicturePath,
                );
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final ThemeChangeCallback toggleTheme;
  final LocaleChangeCallback changeLocale;

  const SettingsPage({
    super.key,
    required this.toggleTheme,
    required this.changeLocale,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool isNotificationEnabled = true;

  String username = 'Memuat...';
  String email = 'Memuat...';
  String? profilePicturePath;
  int? userId;

  Locale selectedLocale = const Locale('id');

  final EvergreenDb db = EvergreenDb();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isNotificationEnabled = prefs.getBool('isNotificationEnabled') ?? true;
      username = prefs.getString('username') ?? 'Pengguna';
      email = prefs.getString('email') ?? 'email@contoh.com';
      userId = prefs.getInt('userId');
      profilePicturePath = prefs.getString('profilePicture');
      selectedLocale = Locale(prefs.getString('languageCode') ?? 'id');
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    widget.toggleTheme(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() => isDarkMode = value);
  }

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationEnabled', value);
    setState(() => isNotificationEnabled = value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? "Notifikasi diaktifkan" : "Notifikasi dinonaktifkan",
          ),
        ),
      );
    }
  }

  Future<void> _changeLanguage(Locale locale) async {
    widget.changeLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() => selectedLocale = locale);
  }

  void _resetDatabase() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Database"),
        content: const Text("Semua data akan dihapus dan Anda akan logout."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await db.resetDatabase();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => SignIn(
                    toggleTheme: widget.toggleTheme,
                    changeLocale: (Locale locale) {},
                  ),
                ),
                (_) => false,
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  void _showProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          currentUsername: username,
          currentEmail: email,
          currentProfilePicturePath: profilePicturePath,
          userId: userId,
          onProfileUpdated: (u, e, p) {
            setState(() {
              username = u;
              email = e;
              profilePicturePath = p;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Akun & Privasi"),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Profil Pengguna"),
              subtitle: Text(username),
              onTap: () => _showProfilePage(context),
            ),
            const Divider(),

            _sectionTitle("Tampilan"),
            SwitchListTile(
              title: const Text("Mode Gelap"),
              secondary: const Icon(Icons.dark_mode),
              value: isDarkMode,
              onChanged: _toggleDarkMode,
            ),
            const Divider(),

            _sectionTitle("Bahasa"),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Bahasa Aplikasi"),
              trailing: DropdownButton<Locale>(
                value: selectedLocale,
                items: const [
                  DropdownMenuItem(
                    value: Locale('id'),
                    child: Text("Indonesia"),
                  ),
                  DropdownMenuItem(value: Locale('en'), child: Text("English")),
                ],
                onChanged: (locale) {
                  if (locale != null) {
                    _changeLanguage(locale);
                  }
                },
              ),
            ),
            const Divider(),

            _sectionTitle("Notifikasi"),
            SwitchListTile(
              title: const Text("Notifikasi"),
              secondary: const Icon(Icons.notifications),
              value: isNotificationEnabled,
              onChanged: _toggleNotification,
            ),
            const Divider(),

            _sectionTitle("Tiket"),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Riwayat Penukaran"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TicketPage()),
                );
              },
            ),
            const Divider(),

            _sectionTitle("Data & Privasi"),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Reset Data Aplikasi"),
              onTap: _resetDatabase,
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}