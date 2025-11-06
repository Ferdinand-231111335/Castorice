import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _beritaFuture = _loadReports(); // Panggil fungsi pemuat baru
  }

  // FUNGSI BARU DENGAN LOGIKA FALLBACK
  Future<List<Berita>> _loadReports() async {
    try {
      // 1. Coba ambil dari API eksternal
      return await api.fetchReports();
    } catch (e) {
      // 2. Jika gagal (termasuk Error 403), ambil dari data lokal
      print('API Error (Fallback Activated): $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengambil data dari ReliefWeb API. Menggunakan data arsip lokal.'),
              backgroundColor: Colors.orange,
            ),
          );
      }
      return await api.fetchLocalReports(); // Ambil dari data lokal
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
            // Tampilkan error jika bahkan data lokal gagal dimuat
            return Center(child: Text('Terjadi kesalahan fatal: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada berita tersedia.'));
          }

          final berita = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _beritaFuture = _loadReports(); // Refresh memanggil ulang logika fallback
              });
            },
            child: ListView.builder(
              itemCount: berita.length,
              itemBuilder: (context, index) {
                final item = berita[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.sumber} • ${formatTanggal(item.tanggal)}'),
                    onTap: () {
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