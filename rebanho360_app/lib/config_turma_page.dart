import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'ebd_presenca_page.dart'; // 🔥 IMPORT NECESSÁRIO
import 'ebd_relatorio_page.dart';


class ConfigTurmaPage extends StatefulWidget {
  final Map turma;

  ConfigTurmaPage({required this.turma});

  @override
  _ConfigTurmaPageState createState() => _ConfigTurmaPageState();
}

class _ConfigTurmaPageState extends State<ConfigTurmaPage> {

  List membros = [];
  int? professorId;

  final titulo = TextEditingController();
  final descricao = TextEditingController();

  Future carregar() async {
    final res = await ApiService.get("/membros");

    if (res.statusCode == 200) {
      setState(() {
        membros = jsonDecode(res.body);
      });
    }
  }

  Future salvarProfessor() async {
    await ApiService.put(
      "/ebd/turmas/${widget.turma["id"]}",
      jsonEncode({
        "professor_id": professorId
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Professor salvo com sucesso")),
    );
  }

  Future salvarLicao() async {
    await ApiService.post(
      "/ebd/licao",
      jsonEncode({
        "titulo": titulo.text,
        "descricao": descricao.text,
        "fk_turma": widget.turma["id"]
      }),
    );

    titulo.clear();
    descricao.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lição salva com sucesso")),
    );
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
        title: Text(widget.turma["nome"] ?? "Turma"),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ==========================
              // PROFESSOR
              // ==========================
              DropdownButtonFormField<int>(
                hint: Text("Selecionar Professor"),
                value: professorId,
                items: membros.map<DropdownMenuItem<int>>((m) {
                  return DropdownMenuItem<int>(
                    value: m["id"],
                    child: Text(m["nome"]),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    professorId = v;
                  });
                },
              ),



              ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EBDRelatorioPage(turma: widget.turma),
      ),
    );
  },
  child: Text("Ver Relatório"),
),

              SizedBox(height: 10),

              ElevatedButton(
                onPressed: salvarProfessor,
                child: Text("Salvar Professor"),
              ),

              SizedBox(height: 30),

              // ==========================
              // LIÇÃO
              // ==========================
              TextField(
                controller: titulo,
                decoration: InputDecoration(
                  labelText: "Título da Lição",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 10),

              TextField(
                controller: descricao,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 10),

              ElevatedButton(
                onPressed: salvarLicao,
                child: Text("Salvar Lição"),
              ),

              SizedBox(height: 30),

              // ==========================
              // PRESENÇA
              // ==========================
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EBDPresencaPage(turma: widget.turma),
                    ),
                  );
                },
                child: Text("Abrir Presença"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}