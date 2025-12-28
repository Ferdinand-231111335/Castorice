import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../api/api_service.dart';
import '../model/berita_model.dart';
import 'berita_detail.dart';
import '../widget/banner_ads.dart';
import '../widget/interstitial_ads.dart';

class BeritaPage extends StatefulWidget {
  const BeritaPage({super.key});

  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  final ReliefWebApi api = ReliefWebApi();
  late Future<List<Berita>> _beritaFuture;

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  int _clickCount = 0;

  @override
  void initState() {
    super.initState();
    _beritaFuture = _loadReports();
    InterstitialAds.load();

    analytics.logEvent(
      name: "berita_page_opened",
      parameters: {"page": "BeritaPage"},
    );
  }

  Future<List<Berita>> _loadReports() async {
    try {
      return await api.fetchReports();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal mengambil data dari ReliefWeb API. Menggunakan data lokal.',
            ),
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

  void _openDetail(Berita item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BeritaDetail(
          judul: item.judul,
          isi: item.isi,
          sumber: item.sumber,
          tanggal: formatTanggal(item.tanggal),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Berita>>(
      future: _beritaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada berita.'));
        }

        final berita = snapshot.data!;

        return Column(
          children: [
            Expanded(
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
                      subtitle: Text(
                        '${item.sumber} • ${formatTanggal(item.tanggal)}',
                      ),
                      onTap: () async {
                        await analytics.logEvent(
                          name: "berita_clicked",
                          parameters: {
                            "judul": item.judul,
                            "sumber": item.sumber,
                          },
                        );

                        _clickCount++;

                        if (_clickCount % 3 == 0) {
                          InterstitialAds.show(
                            onAdClosed: () => _openDetail(item),
                          );
                        } else {
                          _openDetail(item);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const BannerAds(),
          ],
        );
      },
    );
  }
}
