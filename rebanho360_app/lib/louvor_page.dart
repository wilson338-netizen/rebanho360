import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LouvorPage extends StatefulWidget {
  final int eventoId;

  LouvorPage({required this.eventoId});

  @override
  _LouvorPageState createState() => _LouvorPageState();
}

class _LouvorPageState extends State<LouvorPage> {

  Map dados = {};

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {

    final response = await http.get(
      Uri.parse("http://localhost:8000/louvor/${widget.eventoId}")
    );

    if (response.statusCode == 200) {
      setState(() {
        dados = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Louvor"),
      ),

      body: dados.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(10),
              children: [

                // 🎵 MÚSICAS
                Text("🎵 Músicas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                ...dados["musicas"].map<Widget>((m) {
                  return Text("• $m");
                }).toList(),

                SizedBox(height: 20),

                // 🎤 ESCALA
                Text("🎤 Escala",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                ...dados["escala"].entries.map<Widget>((e) {
                  return Text("${e.key}: ${e.value.join(", ")}");
                }).toList(),

                SizedBox(height: 20),

                // 📅 ENSAIO
                Text("📅 Ensaio",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                Text("Dia: ${dados["ensaio"]["data"]}"),
                Text("Horário: ${dados["ensaio"]["horario"]}"),

              ],
            ),
    );
  }
}