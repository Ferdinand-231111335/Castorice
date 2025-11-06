import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../model/berita_model.dart';

class ReliefWebApi {
  static const String baseUrl = 'https://api.reliefweb.int/v1/reports';

  Future<List<Berita>> fetchReports({String country = 'Indonesia', int limit = 20}) async {
    final url = Uri.parse(
      '$baseUrl?appname=evergreen&filter[operator]=AND'
      '&filter[conditions][0][field]=country&filter[conditions][0][value]=$country'
      '&filter[conditions][1][field]=theme.name&filter[conditions][1][value]=Disaster'
      '&profile=full&limit=$limit',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List reports = data['data'] ?? [];
      return reports.map<Berita>((item) => Berita.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data dari ReliefWeb API (${response.statusCode})');
    }
  }

  Future<List<Berita>> fetchLocalReports() async {
    final String response = await rootBundle.loadString('assets/berita.json');
    final List<dynamic> data = json.decode(response);
    
    return data.map<Berita>((item) {
      return Berita(
        judul: item['judul'] ?? 'Tanpa Judul',
        isi: item['isi'] ?? '(Tidak ada isi berita)',
        sumber: 'Arsip Lokal',
        tanggal: DateTime.now().toIso8601String(),
      );
    }).toList();
  }
}