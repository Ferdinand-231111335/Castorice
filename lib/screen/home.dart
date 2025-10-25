import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/about.dart';
import 'package:project_kelompok/screen/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/evergreen_db.dart';
import '../model/misi_model.dart';
import '../model/poin_model.dart';
import 'berita_page.dart';
import 'misi_dart.dart';
import 'poin_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final EvergreenDb db = EvergreenDb();
  int _selectedIndex = 0;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadDataFromDb();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
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

  final List<Widget> _pages = const [
    BeritaPage(),
    MisiPage(),
    PoinPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignIn()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
        title: const Text(
          'Evergreen',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              accountName: Text(username ?? 'Pengguna'),
              accountEmail: const Text(''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green),
              ),
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
