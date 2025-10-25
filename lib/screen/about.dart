import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.eco,
                color: Colors.green,
                size: 100,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Evergreen",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "Versi 1.0.0",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Tentang Evergreen",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Evergreen adalah aplikasi edukatif yang dirancang untuk meningkatkan kesadaran"
              "masyarakat terhadap pelestarian lingkungan. "
              "Melalui fitur berita, misi, dan sistem poin, pengguna dapat belajar, beraksi, "
              "dan mendapatkan penghargaan dari setiap kontribusi hijau yang dilakukan.",
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 10),
            Text(
              "Dikembangkan oleh Castorice © 2025",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
