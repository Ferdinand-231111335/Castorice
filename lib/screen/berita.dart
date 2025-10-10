import 'package:flutter/material.dart';
import '../database/evergreen_db.dart';
import '../model/berita_model.dart';
import 'berita_detail.dart';

class BeritaPage extends StatefulWidget {
  const BeritaPage({super.key});

  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  final EvergreenDb db = EvergreenDb();
  List<Berita> berita = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBerita();
  }

  Future<void> _loadBerita() async {
    final data = await db.getAllBerita();
    setState(() {
      berita = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : berita.isEmpty
              ? const Center(child: Text("Belum ada berita"))
              : RefreshIndicator(
                  onRefresh: _loadBerita, // tarik untuk refresh
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: berita.length,
                    itemBuilder: (context, index) {
                      final item = berita[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: item.gambar.isNotEmpty
                              ? Image.network(
                                  item.gambar,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.image_not_supported),
                          title: Text(
                            item.judul,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            item.isi,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BeritaDetail(berita: item),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
