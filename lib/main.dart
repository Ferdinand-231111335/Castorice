import 'package:flutter/material.dart';
import '../screen/home.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future main() async {
  sqfliteFfiInit();

  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const Home());
  }
}
