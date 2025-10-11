import 'package:flutter/material.dart';
import '../database/evergreen_db.dart';
import '../model/berita_model.dart';

class BeritaDetail extends StatelessWidget {
  final Berita berita;

  const BeritaDetail({super.key, required this.berita});

  Future<Berita?> _loadDetail() async {
    final db = EvergreenDb();

    if (berita.id == null) {
      return berita;
    }

    return await db.getBeritaById(berita.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(berita.judul),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Berita?>(
        future: _loadDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Berita tidak ditemukan.'));
          }

          final item = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.gambar.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.gambar,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                Text(
                  item.judul,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  item.isi,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
