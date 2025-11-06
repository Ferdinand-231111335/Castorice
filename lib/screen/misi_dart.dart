import 'package:flutter/material.dart';
import '../database/evergreen_db.dart';
import '../model/misi_model.dart';

class MisiPage extends StatefulWidget {
  const MisiPage({super.key, required List<dynamic> listMisi});

  @override
  State<MisiPage> createState() => _MisiPageState();
}

class _MisiPageState extends State<MisiPage> {
  final EvergreenDb db = EvergreenDb();
  List<Misi> misi = [];

  @override
  void initState() {
    super.initState();
    _loadMisi();
  }

  Future<void> _loadMisi() async {
    final data = await db.getAllMisi();
    setState(() {
      misi = data;
    });
  }

  void _selesaikanMisi(Misi misiItem) async {
    int current = await db.getTotalPoin();
    await db.updatePoin(1, current + misiItem.poin);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Misi '${misiItem.nama}' selesai! +${misiItem.poin} poin")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: misi.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 3,
          child: ListTile(
            leading: const Icon(Icons.eco, color: Colors.green),
            title: Text(
              misi[index].nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(misi[index].deskripsi),
            trailing: ElevatedButton(
              onPressed: () => _selesaikanMisi(misi[index]),
              child: Text("+${misi[index].poin}"),
            ),
          ),
        );
      },
    );
  }
}
