import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  static const String _baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  static Future<List<Article>> fetchArticles(String type) async {
    final response = await http.get(Uri.parse('$_baseUrl/$type/?limit=20'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((e) => Article.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  static Future<Article> fetchDetail(String type, int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$type/$id/'));
    if (response.statusCode == 200) {
      return Article.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat detail');
    }
  }
}
