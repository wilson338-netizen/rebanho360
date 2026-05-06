import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class EBDRelatorioPage extends StatefulWidget {
  final Map turma;

  EBDRelatorioPage({required this.turma});

  @override
  _EBDRelatorioPageState createState() => _EBDRelatorioPageState();
}

class _EBDRelatorioPageState extends State<EBDRelatorioPage> {

  List dados = [];
  int totalAulas = 0;

  Future carregar() async {

    final res = await ApiService.get(
      "/ebd/relatorio?turma=${widget.turma["id"]}"
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);

      setState(() {
        dados = json["dados"];
        totalAulas = json["total_aulas"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Color corFrequencia(double f) {
    if (f >= 75) return Colors.green;
    if (f >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Relatório - ${widget.turma["nome"]}"),
      ),

      body: Column(
        children: [

          Padding(
            padding: EdgeInsets.all(10),
            child: Text("Total de aulas: $totalAulas"),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: dados.length,
              itemBuilder: (_, i) {

                final m = dados[i];

                return Card(
                  child: ListTile(
                    title: Text(m["nome"]),

                    subtitle: Text(
                      "Presenças: ${m["presencas"]} | Faltas: ${m["faltas"]}",
                    ),

                    trailing: Text(
                      "${m["frequencia"]}%",
                      style: TextStyle(
                        color: corFrequencia(
                          (m["frequencia"] as num).toDouble()
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}

