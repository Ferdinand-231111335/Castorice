import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/signin.dart';
import 'package:project_kelompok/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import './database/evergreen_db.dart';

typedef ThemeChangeCallback = void Function(bool isDark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn, initialDarkMode: isDarkMode)); 
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool initialDarkMode;
  const MyApp({super.key, required this.isLoggedIn, required this.initialDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark); 

    if (mounted) {
      setState(() {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Evergreen', 
      themeMode: _themeMode, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light),
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        primaryColor: Colors.green[700],
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[850],
        useMaterial3: true,
      ),
      home: widget.isLoggedIn 
          ? Home(toggleTheme: toggleTheme)
          : SignIn(toggleTheme: toggleTheme),
    );
  }
}