import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../api/api_service.dart';
import '../model/berita_model.dart';
import 'berita_detail.dart';

class BeritaPage extends StatefulWidget {
  const BeritaPage({super.key});

  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  final ReliefWebApi api = ReliefWebApi();
  late Future<List<Berita>> _beritaFuture;

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _beritaFuture = _loadReports();

    analytics.logEvent(
      name: "berita_page_opened",
      parameters: {"page": "BeritaPage"},
    );
  }

  Future<List<Berita>> _loadReports() async {
    try {
      return await api.fetchReports();
    } catch (e) {
      print('API Error (Fallback Activated): $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengambil data dari ReliefWeb API. Menggunakan data arsip lokal.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return await api.fetchLocalReports();
    }
  }

  String formatTanggal(String tanggal) {
    try {
      final parsed = DateTime.parse(tanggal);
      return DateFormat('dd MMMM yyyy').format(parsed);
    } catch (_) {
      return 'Tanggal tidak diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Berita>>(
        future: _beritaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan fatal: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada berita tersedia.'));
          }

          final berita = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _beritaFuture = _loadReports();
              });

              await analytics.logEvent(
                name: "berita_refresh",
                parameters: {"method": "pull_to_refresh"},
              );
            },
            child: ListView.builder(
              itemCount: berita.length,
              itemBuilder: (context, index) {
                final item = berita[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      item.judul,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${item.sumber} • ${formatTanggal(item.tanggal)}'),
                    onTap: () async {
                      await analytics.logEvent(
                        name: "berita_clicked",
                        parameters: {
                          "judul": item.judul,
                          "sumber": item.sumber,
                        },
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BeritaDetail(
                            judul: item.judul,
                            isi: item.isi,
                            sumber: item.sumber,
                            tanggal: formatTanggal(item.tanggal),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
