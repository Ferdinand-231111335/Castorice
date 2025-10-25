import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class BeritaDetail extends StatelessWidget {
  final String judul;
  final String isi;
  final String sumber;
  final String tanggal;

  const BeritaDetail({
    super.key,
    required this.judul,
    required this.isi,
    required this.sumber,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(judul, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Sumber: $sumber",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    tanggal,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Html(
                data: isi,
                style: {
                  "body": Style(
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.5),
                    color: Colors.black87,
                  ),
                  "a": Style(color: Colors.green),
                  "strong": Style(fontWeight: FontWeight.bold),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
