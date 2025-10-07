class Misi {
  final int? id;
  final String nama;
  final String deskripsi;
  final int poin;

  Misi({this.id, required this.nama, required this.deskripsi, required this.poin});

  Map<String, dynamic> toMap() {
    return {"id": id, "nama": nama, "deskripsi": deskripsi, "poin": poin};
  }

  factory Misi.fromMap(Map<String, dynamic> map) {
    return Misi(
      id: map["id"],
      nama: map["nama"],
      deskripsi: map["deskripsi"],
      poin: map["poin"],
    );
  }
}
