import 'dart:convert';
import 'package:http/http.dart' as http;
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
}
