import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class EBDTurmasPage extends StatefulWidget {
  @override
  _EBDTurmasPageState createState() => _EBDTurmasPageState();
}

class _EBDTurmasPageState extends State<EBDTurmasPage> {

  List turmas = [];
  List membros = [];

  int? professorId;
  String nomeTurma = "";

  Future carregar() async {
    final t = await ApiService.get("/ebd/turmas");
    final m = await ApiService.get("/membros");

    if (t.statusCode == 200 && m.statusCode == 200) {
      setState(() {
        turmas = jsonDecode(t.body);
        membros = jsonDecode(m.body);
      });
    }
  }

  Future salvar() async {
    await ApiService.post("/ebd/turmas", {
      "nome": nomeTurma,
      "professor_id": professorId
    });

    nomeTurma = "";
    professorId = null;

    carregar();
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Turmas EBD")),

      body: Column(
        children: [

          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [

                TextField(
                  decoration: InputDecoration(labelText: "Nome da turma"),
                  onChanged: (v) => nomeTurma = v,
                ),

                DropdownButtonFormField(
                  hint: Text("Professor"),
                  value: professorId,
                  items: membros.map((m) {
                    return DropdownMenuItem(
                      value: m["id"],
                      child: Text(m["nome"]),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      professorId = v as int?;
                    });
                  },
                ),

                SizedBox(height: 10),

                ElevatedButton(
                  onPressed: salvar,
                  child: Text("Salvar Turma"),
                )
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: turmas.length,
              itemBuilder: (_, i) {
                final t = turmas[i];

                return ListTile(
                  title: Text(t["nome"]),
                  subtitle: Text("Professor: ${t["professor_nome"] ?? "Não definido"}"),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

