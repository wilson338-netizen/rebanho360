import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // 🔥 AGORA APONTANDO PARA PRODUÇÃO
  static const String baseUrl = "https://web-production-88cd7.up.railway.app";

  // ==========================
  // HEADERS PADRÃO
  // ==========================
  static Future<Map<String, String>> getHeaders() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    print("TOKEN GLOBAL: $token"); // DEBUG

    return {
      "Content-Type": "application/json",
      "Authorization": token != null ? "Bearer $token" : "",
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
