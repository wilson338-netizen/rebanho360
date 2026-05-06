import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EscalaEventoPage extends StatefulWidget {

  final int eventoId;

  EscalaEventoPage({required this.eventoId});

  @override
  _EscalaEventoPageState createState() => _EscalaEventoPageState();
}

class _EscalaEventoPageState extends State<EscalaEventoPage> {

  List escala = [];

  // ==========================
  // CARREGAR ESCALA
  // ==========================
  Future carregar() async {

    final res = await http.get(
      Uri.parse("http://localhost:8000/escala/${widget.eventoId}")
    );

    setState(() {
      escala = jsonDecode(res.body);
    });
  }

  // ==========================
  // GERAR ESCALA
  // ==========================
  Future gerarEscala() async {

    final res = await http.post(
      Uri.parse("http://localhost:8000/escala/gerar_por_evento"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "evento_id": widget.eventoId
      }),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Escala gerada com sucesso 🎉"))
      );

      carregar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao gerar escala"))
      );
    }
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Escala do Evento"),
        actions: [

          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: carregar,
          ),

          IconButton(
            icon: Icon(Icons.auto_awesome, color: Colors.amber),
            onPressed: gerarEscala,
          ),

        ],
      ),

      body: escala.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(Icons.event_busy, size: 80, color: Colors.grey),

                  SizedBox(height: 10),

                  Text(
                    "Nenhuma escala gerada",
                    style: TextStyle(fontSize: 18),
                  ),

                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: carregar,
                    child: Text("Atualizar"),
                  )

                ],
              ),
            )
          : ListView.builder(
              itemCount: escala.length,
              itemBuilder: (context, index) {

                final e = escala[index];

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.group, color: Colors.green),
                    title: Text(e["nome"]),
                    subtitle: Text(e["funcao"]),
                  ),
                );
              },
            ),
    );
  }
}

