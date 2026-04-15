import 'dart:convert';
import 'package:http/http.dart' as http;

class FunctionsService {
  Future<Map<String, dynamic>> testConnection() async {
    const url =
        "https://us-central1-schoolquizapp-8b07d.cloudfunctions.net/helloWorldCallable";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> exportToGoogleForms(Map<String, dynamic> payload) async {
    const url =
        "https://us-central1-schoolquizapp-8b07d.cloudfunctions.net/exportToGoogleForms";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body);
  }
}