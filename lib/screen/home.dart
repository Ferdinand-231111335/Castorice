import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/evergreen_db.dart';
import '../model/berita_model.dart';
import '../model/misi_model.dart';
import '../model/poin_model.dart';
import 'berita.dart';
import 'misi.dart';
import 'poin.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final EvergreenDb db = EvergreenDb();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDataFromDb();
  }

  Future<void> _loadDataFromDb() async {
    // cek berita
    final beritaData = await db.getAllBerita();
    if (beritaData.isEmpty) {
      await _insertBeritaFromJson();
    }

    // cek misi
    final misiData = await db.getAllMisi();
    if (misiData.isEmpty) {
      await _insertMisiFromJson();
    }

    // cek poin
    int currentPoin = await db.getTotalPoin();
    if (currentPoin == 0) {
      await db.insertPoin(Poin(total: 0));
    }
  }

 Future<void> _insertBeritaFromJson() async {
  String jsonString = await rootBundle.loadString('assets/berita.json');
  List<dynamic> jsonData = json.decode(jsonString);

  for (var item in jsonData) {
    final berita = Berita.fromJson(item);  // pakai fromJson
    await db.insertBerita(berita);
  }
}

Future<void> _insertMisiFromJson() async {
  String jsonString = await rootBundle.loadString('assets/misi.json');
  List<dynamic> jsonData = json.decode(jsonString);

  for (var item in jsonData) {
    final misi = Misi.fromJson(item);  // pakai fromJson
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('isLoggedIn'); // atau prefs.setBool('isLoggedIn', false);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignIn()),
                (route) => false,
              );
            },
          )
        ],

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