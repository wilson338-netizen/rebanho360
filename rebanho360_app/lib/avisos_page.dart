import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AvisosPage extends StatefulWidget {
  @override
  _AvisosPageState createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {

  List avisos = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {
    final res = await http.get(
      Uri.parse("http://localhost:8000/avisos"),
    );

    if (res.statusCode == 200) {
      setState(() {
        avisos = jsonDecode(res.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Avisos"),
      ),
      body: ListView.builder(
        itemCount: avisos.length,
        itemBuilder: (context, i) {
          final item = avisos[i];

          return ListTile(
            title: Text(item["titulo"] ?? ""),
            subtitle: Text(item["mensagem"] ?? ""),
          );
        },
      ),
    );
  }
}
