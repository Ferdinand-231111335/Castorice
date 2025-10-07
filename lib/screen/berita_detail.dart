import 'package:flutter/material.dart';
import '../model/berita_model.dart';

class BeritaDetail extends StatelessWidget {
  final Berita berita;

  const BeritaDetail({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(berita.judul),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          berita.isi,
          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
      ),
    );
  }
}
