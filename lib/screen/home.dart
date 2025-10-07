import 'package:flutter/material.dart';
import '../database/evergreen_db.dart';
import '../model/berita_model.dart';
import '../model/misi_model.dart';
import '../model/poin_model.dart';
import 'berita_detail.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EvergreenDb db = EvergreenDb(); // database

  List<Berita> berita = [];
  List<Misi> misi = [];
  int totalPoin = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    // bersihkan dan isi data dummy
    await db.clearBerita();
    await db.clearMisi();

    // dummy berita
    List<Berita> beritaDummy = [
      Berita(judul: "Banjir Bandang di Kalimantan", isi: "Curah hujan ekstrem akibat perubahan iklim memicu banjir bandang."),
      Berita(judul: "Kebakaran Hutan Amazon", isi: "Gelombang panas memicu kebakaran hutan Amazon terbesar dalam 10 tahun."),
      Berita(judul: "Es Kutub Mencair", isi: "Pencairan es di kutub meningkat lebih cepat dari prediksi ilmuwan."),
    ];
    for (var item in beritaDummy) {
      await db.insertBerita(item);
    }

    // dummy misi
    List<Misi> misiDummy = [
      Misi(nama: "Kurangi Plastik", deskripsi: "Gunakan tas kain saat belanja.", poin: 10),
      Misi(nama: "Hemat Listrik", deskripsi: "Matikan lampu saat tidak digunakan.", poin: 15),
      Misi(nama: "Tanam Pohon", deskripsi: "Tanam minimal 1 pohon di sekitar rumah.", poin: 25),
    ];
    for (var item in misiDummy) {
      await db.insertMisi(item);
    }

    // insert poin awal
    int currentPoin = await db.getTotalPoin();
    if (currentPoin == 0) {
      await db.insertPoin(Poin(total: 0));
    }

    // load ulang
    final beritaData = await db.getAllBerita();
    final misiData = await db.getAllMisi();
    final poinData = await db.getTotalPoin();

    setState(() {
      berita = beritaData;
      misi = misiData;
      totalPoin = poinData;
    });
  }

  void _selesaikanMisi(Misi misiItem) async {
    int current = await db.getTotalPoin();
    await db.updatePoin(1, current + misiItem.poin);
    final newTotal = await db.getTotalPoin();

    setState(() {
      totalPoin = newTotal;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Misi '${misiItem.nama}' selesai! +${misiItem.poin} poin")),
    );
  }

  void _redeemPoin(int biaya, String hadiah) async {
    int current = await db.getTotalPoin();
    if (current >= biaya) {
      await db.updatePoin(1, current - biaya);
      final newTotal = await db.getTotalPoin();

      setState(() {
        totalPoin = newTotal;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil menukar $biaya poin untuk $hadiah 🎉")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Poin tidak cukup untuk menukar $hadiah 😢")),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
        title: Column(
          mainAxisSize: MainAxisSize.max,
          children: const [
            Center(
              child: Text(
                'Evergreen App',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            SizedBox(height: 10),
            Divider(thickness: 2, color: Colors.black),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "Berita", icon: Icon(Icons.article)),
            Tab(text: "Misi", icon: Icon(Icons.flag)),
            Tab(text: "Tukar Poin", icon: Icon(Icons.card_giftcard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ================= Halaman Berita =================
ListView.builder(
  itemCount: berita.length,
  itemBuilder: (context, index) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: Text(
          berita[index].judul,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          berita[index].isi,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BeritaDetail(berita: berita[index]),
            ),
          );
        },
      ),
    );
  },
),

          // ================= Halaman Misi =================
          ListView.builder(
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
          ),

          // ================= Halaman Tukar Poin =================
Column(
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
)

        ],
      ),
    );
  }
}
