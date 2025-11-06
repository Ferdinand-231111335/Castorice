import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
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
  final EvergreenDb db = EvergreenDb();
  int _selectedIndex = 0;
  String? username;
  String? profilePicturePath;
  int? totalPoin;
  
  // Variabel untuk Jam Realtime
  late Timer _timer;
  String _currentTimeWIB = '';

  final List<Widget> _pages = const [
    BeritaPage(), 
    MisiPage(listMisi: [],),   
    PoinPage(),   
  ];

  @override
  void initState() {
    super.initState();
    _loadDataFromDb();
    _loadUserData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateTime(); 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    // Format waktu ke HH:mm:ss (WIB)
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm:ss'); 
    
    if (mounted) {
      setState(() {
        _currentTimeWIB = formatter.format(now);
      });
    }
  }


  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final int poin = await db.getTotalPoin(); 

    if (mounted) {
      setState(() {
        username = prefs.getString('username') ?? 'Pengguna';
        profilePicturePath = prefs.getString('profilePicture');
        totalPoin = poin;
      });
    }
  }

  Future<void> _loadDataFromDb() async {
    final misiData = await db.getAllMisi();
    if (misiData.isEmpty) {
      await _insertMisiFromJson();
    }

    int currentPoin = await db.getTotalPoin();
    if (currentPoin == 0) {
      await db.insertPoin(Poin(total: 0));
    }
  }

  Future<void> _insertMisiFromJson() async {
    String jsonString = await rootBundle.loadString('assets/misi.json');
    List<dynamic> jsonData = json.decode(jsonString);

    for (var item in jsonData) {
      final misi = Misi.fromJson(item);
      await db.insertMisi(misi);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SignIn(toggleTheme: widget.toggleTheme)),
        (route) => false,
      );
    }
  }

  Widget _buildProfileAvatar() {
    if (profilePicturePath != null && File(profilePicturePath!).existsSync()) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: FileImage(File(profilePicturePath!)),
      );
    }
    
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return CircleAvatar(
      backgroundColor: isDark ? Colors.grey[700] : Colors.white,
      child: const Icon(Icons.person, size: 40, color: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color drawerHeaderColor = isDark ? Colors.black : Colors.green;

    final poinText = totalPoin.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: isDark ? Colors.white : Colors.black,
        title: const Text(
          'Evergreen',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,

        // TAMBAH: Widget Jam Realtime di actions
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                _currentTimeWIB,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black, 
                ),
              ),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: drawerHeaderColor),
              // MODIFIKASI: Hapus Row, kembalikan accountName seperti semula
              accountName: Text(
                username ?? 'Pengguna',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              accountEmail: Text(
                'Total Poin: $poinText',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black, 
                ),
              ),
              currentAccountPicture: _buildProfileAvatar(), 
            ),
            
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(toggleTheme: widget.toggleTheme),
                  ),
                );
                
                _loadUserData(); 
              },
            ),

            ListTile(
              leading: const Icon(Icons.local_activity),
              title: const Text('Voucher Saya'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicketPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const About()),
                );
              },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Berita",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: "Misi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: "Poin",
          ),
        ],
      ),
    );
  }
}