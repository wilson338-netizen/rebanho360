import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // 🔥 PRODUÇÃO
  static const String baseUrl = "https://web-production-88cd7.up.railway.app";

  // ==========================
  // TOKEN
  // ==========================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ==========================
  // HEADERS PADRÃO
  // ==========================
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  // ==========================
  // GET
  // ==========================
  static Future<http.Response> get(String endpoint) async {
    final headers = await getHeaders();

    return await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
    );
  }

  // ==========================
  // POST
  // ==========================
  static Future<http.Response> post(
    String endpoint,
    dynamic body,
  ) async {

    final headers = await getHeaders();

    return await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
      body: body is String ? body : jsonEncode(body),
    );
  }

  // ==========================
  // PUT
  // ==========================
  static Future<http.Response> put(
    String endpoint,
    dynamic body,
  ) async {

    final headers = await getHeaders();

    return await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
      body: body is String ? body : jsonEncode(body),
    );
  }

  // ==========================
  // DELETE
  // ==========================
  static Future<http.Response> delete(String endpoint) async {
    final headers = await getHeaders();

    return await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
    );
  }
}

