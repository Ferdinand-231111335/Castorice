import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../model/misi_model.dart';


class MisiPage extends StatefulWidget {
  const MisiPage({super.key});

  @override
  State<MisiPage> createState() => _MisiPageState();
}

class _MisiPageState extends State<MisiPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  List<Misi> misi = [];

  @override
  void initState() {
    super.initState();
    _loadMisi();

    analytics.logEvent(
      name: "misi_page_opened",
      parameters: {"page": "MisiPage"},
    );
  }

  /// 🔹 Load misi (masih lokal / static)
  void _loadMisi() {
    setState(() {
      misi = [
        Misi(nama: "Menanam Pohon", deskripsi: "Tanam 1 pohon", poin: 20),
        Misi(nama: "Hemat Air", deskripsi: "Kurangi pemakaian air", poin: 15),
        Misi(nama: "Daur Ulang", deskripsi: "Daur ulang sampah", poin: 25),
      ];
    });

    analytics.logEvent(
      name: "misi_list_loaded",
      parameters: {"total_misi": misi.length},
    );
  }

  /// 🔥 Selesaikan misi → UPDATE FIRESTORE
  Future<void> _selesaikanMisi(Misi misiItem) async {
    final user = auth.currentUser;
    if (user == null) return;

    final userRef = firestore.collection('users').doc(user.uid);

    try {
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);

        final currentPoin = snapshot.data()?['poin'] ?? 0;
        transaction.update(userRef, {
          'poin': currentPoin + misiItem.poin,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Misi '${misiItem.nama}' selesai! +${misiItem.poin} poin",
          ),
        ),
      );

      analytics.logEvent(
        name: "misi_completed",
        parameters: {
          "nama_misi": misiItem.nama,
          "poin": misiItem.poin,
        },
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyelesaikan misi")),
      );
    }
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
