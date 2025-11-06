import 'package:flutter/material.dart';
import 'package:project_kelompok/model/tiket_model.dart';
import '../database/evergreen_db.dart';

class PoinPage extends StatefulWidget {
  const PoinPage({super.key});

  @override
  State<PoinPage> createState() => _PoinPageState();
}

class _PoinPageState extends State<PoinPage> {
  final EvergreenDb db = EvergreenDb();
  int totalPoin = 0;

  @override
  void initState() {
    super.initState();
    _loadPoin();
  }

  Future<void> _loadPoin() async {
    final data = await db.getTotalPoin();
    setState(() {
      totalPoin = data;
    });
  }

  void _redeemPoin(int biaya, String hadiah) async {
    int current = await db.getTotalPoin();
    if (current >= biaya) {
      await db.updatePoin(1, current - biaya);
      
      await db.insertTicket(
        Ticket(
          hadiah: hadiah,
          poin: biaya, 
          tanggal: DateTime.now().toIso8601String(),
        ),
      );

      setState(() {
        totalPoin -= biaya;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil menukar $biaya poin untuk $hadiah. Tiket telah dicatat.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Poin tidak cukup untuk $hadiah")),
      );
    }
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
        const SizedBox(height: 10),
        const Divider(thickness: 2, color: Colors.grey),

        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.card_giftcard, color: Colors.blue),
                title: const Text("Merchandise Evergreen"),
                subtitle: const Text("Tukar dengan 80 poin"),
                trailing: ElevatedButton(
                  onPressed: () => _redeemPoin(80, "Merchandise Evergreen"),
                  child: const Text("Tukar"),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.orange),
                title: const Text("Voucher Belanja"),
                subtitle: const Text("Tukar dengan 50 poin"),
                trailing: ElevatedButton(
                  onPressed: () => _redeemPoin(50, "Voucher Belanja"),
                  child: const Text("Tukar"),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.fastfood, color: Colors.red),
                title: const Text("Voucher Makanan"),
                subtitle: const Text("Tukar dengan 100 poin"),
                trailing: ElevatedButton(
                  onPressed: () => _redeemPoin(100, "Voucher Makanan"),
                  child: const Text("Tukar"),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.park, color: Colors.green),
                title: const Text("Donasi Tanam Pohon"),
                subtitle: const Text("Tukar dengan 200 poin"),
                trailing: ElevatedButton(
                  onPressed: () => _redeemPoin(200, "Donasi Tanam Pohon"),
                  child: const Text("Tukar"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}