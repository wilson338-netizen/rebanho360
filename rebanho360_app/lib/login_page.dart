import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'app_membro.dart';
import 'cadastro_igreja_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();

  final String baseUrl = "http://localhost:8000";

  void login() async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.text,
          "senha": senha.text
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro no login")),
        );
        return;
      }

     final data = jsonDecode(response.body);

if (data["erro"] != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(data["erro"])),
  );
  return;
}

      String token = data["token"];
      String tipo = data["tipo"] ?? "membro";
      int membroId = data["membro_id"] ?? 0;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      if (tipo == "membro") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AppMembro(membroId: membroId),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(tipoUsuario: tipo),
          ),
        );
      }

    } catch (e) {
      print("ERRO LOGIN: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao conectar com servidor")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: Card(
          elevation: 5,
          child: Container(
            width: 350,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Icon(Icons.church, size: 80, color: Colors.blue),

                SizedBox(height: 20),

                Text(
                  "Rebanho360",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 15),

                TextField(
                  controller: senha,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    child: Text("Entrar"),
                  ),
                ),

                SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CadastroIgrejaPage(),
                      ),
                    );
                  },
                  child: Text("Criar conta / Cadastrar Igreja"),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

