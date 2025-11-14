import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../database/evergreen_db.dart';
import '../model/misi_model.dart';

class MisiPage extends StatefulWidget {
  const MisiPage({super.key, required List<dynamic> listMisi});

  @override
  State<MisiPage> createState() => _MisiPageState();
}

class _MisiPageState extends State<MisiPage> {
  final EvergreenDb db = EvergreenDb();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  List<Misi> misi = [];

  @override
  void initState() {
    super.initState();
    _loadMisi();

    // 📌 EVENT: Halaman misi dibuka
    analytics.logEvent(
      name: "misi_page_opened",
      parameters: {"page": "MisiPage"},
    );
  }

  Future<void> _loadMisi() async {
    final data = await db.getAllMisi();
    setState(() {
      misi = data;
    });

    // 📌 EVENT: Data misi berhasil di-load
    analytics.logEvent(
      name: "misi_list_loaded",
      parameters: {
        "total_misi": data.length,
      },
    );
  }

  void _selesaikanMisi(Misi misiItem) async {
    int current = await db.getTotalPoin();
    await db.updatePoin(1, current + misiItem.poin);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Misi '${misiItem.nama}' selesai! +${misiItem.poin} poin"),
      ),
    );

    // 📌 EVENT: Misi diselesaikan
    analytics.logEvent(
      name: "misi_completed",
      parameters: {
        "nama_misi": misiItem.nama,
        "poin": misiItem.poin,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: misi.length,
      itemBuilder: (context, index) {
        final item = misi[index];

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 3,
          child: ListTile(
            leading: const Icon(Icons.eco, color: Colors.green),
            title: Text(
              item.nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item.deskripsi),
            trailing: ElevatedButton(
              onPressed: () => _selesaikanMisi(item),
              child: Text("+${item.poin}"),
            ),
          ),
        );
      },
    );
  }
}
