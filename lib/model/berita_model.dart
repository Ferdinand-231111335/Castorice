class Berita {
  final int? id; // id bisa null kalau data baru (belum disimpan di DB)
  final String judul;
  final String isi;

  Berita({this.id, required this.judul, required this.isi});

  // Convert dari Map (data DB) ke object
  factory Berita.fromMap(Map<String, dynamic> map) {
    return Berita(
      id: map['id'],
      judul: map['judul'],
      isi: map['isi'],
    );
  }

  // Convert dari object ke Map (buat simpan ke DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
    };
  }
}
