import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class PoinPage extends StatefulWidget {
  const PoinPage({super.key});

  @override
  State<PoinPage> createState() => _PoinPageState();
}

class _PoinPageState extends State<PoinPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  int totalPoin = 0;
  String get uid => _auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadPoin();
  }

  Future<void> _loadPoin() async {
    final doc =
        await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      setState(() {
        totalPoin = doc['poin'] ?? 0;
      });
    }
  }

  Future<void> _redeemPoin(int biaya, String hadiah) async {
    if (totalPoin < biaya) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Poin tidak cukup untuk $hadiah")),
      );
      return;
    }

    final userRef = _firestore.collection('users').doc(uid);
    final ticketRef = userRef.collection('tickets').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentPoin = snapshot['poin'];

      transaction.update(userRef, {
        'poin': currentPoin - biaya,
      });

      transaction.set(ticketRef, {
        'hadiah': hadiah,
        'poin': biaya,
        'tanggal': FieldValue.serverTimestamp(),
      });
    });

    analytics.logEvent(
      name: "redeem_success",
      parameters: {
        "hadiah": hadiah,
        "biaya": biaya,
      },
    );

    await _loadPoin();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Berhasil menukar $biaya poin untuk $hadiah")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "Total Poin Kamu: $totalPoin",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Divider(thickness: 2),
        Expanded(
          child: ListView(
            children: [
              _buildItem("Voucher Belanja", 50, Icons.shopping_cart),
              _buildItem("Merchandise Evergreen", 80, Icons.card_giftcard),
              _buildItem("Voucher Makanan", 100, Icons.fastfood),
              _buildItem("Donasi Tanam Pohon", 200, Icons.park),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String hadiah, int biaya, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(hadiah),
      subtitle: Text("Tukar dengan $biaya poin"),
      trailing: ElevatedButton(
        onPressed: () => _redeemPoin(biaya, hadiah),
        child: const Text("Tukar"),
      ),
    );
  }
}
