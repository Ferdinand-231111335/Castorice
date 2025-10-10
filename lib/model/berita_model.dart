class Berita {
  final int? id;
  final String judul;
  final String isi;
  final String gambar;

  Berita({
    this.id,
    required this.judul,
    required this.isi,
    required this.gambar,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['id'],
      judul: json['judul'],
      isi: json['isi'],
      gambar: json['gambar'],
    );
  }

  factory Berita.fromMap(Map<String, dynamic> map) {
    return Berita(
      id: map['id'],
      judul: map['judul'] ?? "",
      isi: map['isi'] ?? "",
      gambar: map['gambar'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'gambar': gambar,
    };
  }
}
