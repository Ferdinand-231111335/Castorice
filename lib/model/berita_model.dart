class Berita {
  final String judul;
  final String isi;
  final String sumber;
  final String tanggal;

  Berita({
    required this.judul,
    required this.isi,
    required this.sumber,
    required this.tanggal,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    final fields = json['fields'] ?? {};

    String sumber = 'Tidak diketahui';
    if (fields['source'] != null && (fields['source'] as List).isNotEmpty) {
      sumber = fields['source'][0]['name'] ?? 'Tidak diketahui';
    }

    String tanggal = 'Tanggal tidak diketahui';
    if (fields['date'] != null && fields['date']['created'] != null) {
      tanggal = fields['date']['created'];
    }

    String isi = '';
    if (fields['body-html'] != null && fields['body-html'].toString().isNotEmpty) {
      isi = fields['body-html'].toString().replaceAll(RegExp(r'<[^>]*>'), '');
    } else if (fields['body'] != null && fields['body'].toString().isNotEmpty) {
      isi = fields['body'].toString();
    } else {
      isi = '(Tidak ada isi berita)';
    }

    return Berita(
      judul: fields['title'] ?? 'Tanpa Judul',
      isi: isi,
      sumber: sumber,
      tanggal: tanggal,
    );
  }
}
