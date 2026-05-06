import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'config_turma_page.dart';

class SegmentosPage extends StatefulWidget {
  @override
  _SegmentosPageState createState() => _SegmentosPageState();
}

class _SegmentosPageState extends State<SegmentosPage> {

  List segmentos = [];
  TextEditingController nome = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregar();
  }

  // ==========================
  // CARREGAR TURMAS (EBD)
  // ==========================
  Future carregar() async {
    final res = await ApiService.get("/ebd/turmas");

    if (res.statusCode == 200) {
      setState(() {
        segmentos = jsonDecode(res.body);
      });
    }
  }

  // ==========================
  // CRIAR NOVA TURMA
  // ==========================
  Future salvar() async {

    if (nome.text.isEmpty) return;

    await ApiService.post(
      "/ebd/turmas",
      jsonEncode({
        "nome": nome.text,
        "professor_id": null
      }),
    );

    nome.clear();
    carregar();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Segmentos EBD"),
      ),

      body: Column(
        children: [

          // ==========================
          // INPUT NOVA TURMA
          // ==========================
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: nome,
                    decoration: InputDecoration(
                      labelText: "Nome da Turma",
                    ),
                  ),
                ),

                SizedBox(width: 10),

                ElevatedButton(
                  onPressed: salvar,
                  child: Text("Salvar"),
                ),

              ],
            ),
          ),

          // ==========================
          // LISTA DE TURMAS
          // ==========================
          Expanded(
            child: segmentos.isEmpty
                ? Center(child: Text("Nenhuma turma cadastrada"))
                : ListView.builder(
                    itemCount: segmentos.length,
                    itemBuilder: (_, i) {

                      final s = segmentos[i];

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(s["nome"] ?? ""),
                          subtitle: Text(
                            "Professor: ${s["professor_nome"] ?? "Não definido"}",
                          ),

                          trailing: Icon(Icons.settings),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfigTurmaPage(turma: s),
                              ),
                            );
                          },
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

