import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart'; // 🔥 IMPORT NECESSÁRIO

class EscalaPage extends StatefulWidget {
  final int eventoId;

  EscalaPage({required this.eventoId});

  @override
  _EscalaPageState createState() => _EscalaPageState();
}

class _EscalaPageState extends State<EscalaPage> {

  List escala = [];

  @override
  void initState() {
    super.initState();
    gerarEscala();
  }

  // ==========================
  // GERAR ESCALA
  // ==========================
  Future gerarEscala() async {

    final res = await ApiService.post(
      "/escala/gerar_por_evento",
      jsonEncode({
        "evento_id": widget.eventoId
      }),
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200) {

      final data = jsonDecode(res.body);

      setState(() {
        escala = data["escala"] ?? [];
      });

    } else {
      print("Erro escala: ${res.body}");
    }
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Escala do Evento"),
      ),

      body: escala.isEmpty
          ? Center(child: Text("Nenhuma escala gerada"))
          : ListView.builder(
              itemCount: escala.length,
              itemBuilder: (context, index) {

                final item = escala[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(item["nome"] ?? ""),
                    subtitle: Text("Função: ${item["funcao"]}"),
                  ),
                );
              },
            ),
    );
  }
}

