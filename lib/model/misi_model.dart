class Misi {
  final int? id;
  final String nama;
  final String deskripsi;
  final int poin;

  Misi({
    this.id,
    required this.nama,
    required this.deskripsi,
    required this.poin,
  });

  // dari database (Map)
  factory Misi.fromMap(Map<String, dynamic> map) {
    return Misi(
      id: map['id'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      poin: map['poin'],
    );
  }

  // ke database (Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'poin': poin,
    };
  }

  // dari JSON
  factory Misi.fromJson(Map<String, dynamic> json) {
    return Misi(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      poin: json['poin'],
    );
  }

  // ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'poin': poin,
    };
  }
}
