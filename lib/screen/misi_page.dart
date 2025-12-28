import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../model/misi_model.dart';
import '../widget/rewarded_ads.dart';

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
  bool _isWatchingAd = false;

  @override
  void initState() {
    super.initState();
    _loadMisi();
    RewardedAds.load();

    analytics.logEvent(
      name: "misi_page_opened",
      parameters: {"page": "MisiPage"},
    );
  }

  void _loadMisi() {
    setState(() {
      misi = [
        Misi(nama: "Menanam Pohon", deskripsi: "Tanam 1 pohon", poin: 20),
        Misi(nama: "Hemat Air", deskripsi: "Kurangi pemakaian air", poin: 15),
        Misi(nama: "Daur Ulang", deskripsi: "Daur ulang sampah", poin: 25),
        Misi(
          nama: "Tonton Iklan",
          deskripsi: "Tonton iklan untuk mendapatkan poin",
          poin: 25,
        ),
      ];
    });

    analytics.logEvent(
      name: "misi_list_loaded",
      parameters: {"total_misi": misi.length},
    );
  }

  Future<void> _tambahPoin(int poin, String sumber) async {
    final user = auth.currentUser;
    if (user == null) return;

    final userRef = firestore.collection('users').doc(user.uid);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentPoin = snapshot.data()?['poin'] ?? 0;

      transaction.update(userRef, {
        'poin': currentPoin + poin,
      });
    });

    analytics.logEvent(
      name: "poin_didapat",
      parameters: {
        "jumlah": poin,
        "sumber": sumber,
      },
    );
  }

  Future<void> _selesaikanMisi(Misi misiItem) async {
    if (misiItem.nama == "Tonton Iklan") return;

    await _tambahPoin(misiItem.poin, misiItem.nama);

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
  }

  void _selesaikanMisiIklan(Misi misiItem) {
    if (_isWatchingAd) return;

    _isWatchingAd = true;

    RewardedAds.show(
      onUserEarnedReward: () async {
        await _tambahPoin(misiItem.poin, "rewarded_ads");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Kamu dapat ${misiItem.poin} poin dari iklan!",
              ),
            ),
          );
        }
      },
      onAdClosed: () {
        _isWatchingAd = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: misi.length,
      itemBuilder: (context, index) {
        final item = misi[index];

        final isIklan = item.nama == "Tonton Iklan";

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 3,
          child: ListTile(
            leading: Icon(
              isIklan ? Icons.play_circle : Icons.eco,
              color: Colors.green,
            ),
            title: Text(
              item.nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item.deskripsi),
            trailing: ElevatedButton(
              onPressed: isIklan
                  ? () => _selesaikanMisiIklan(item)
                  : () => _selesaikanMisi(item),
              child: Text("+${item.poin}"),
            ),
          ),
        );
      },
    );
  }
}
