// ==========================================
// IMPORTAÇÕES
// ==========================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'models/pg_model.dart';
import 'models/presenca_model.dart';
import 'selecionar_membros_pg_page.dart';
import 'frequencia_pg_page.dart';
import 'alerta_pg_page.dart';


import 'package:rebanho360_app/api_service.dart';

final String baseUrl = "${ApiService.baseUrl}";

// ==========================================
// PAGE
// ==========================================

class PGDetalhePage extends StatefulWidget {
  final PG pg;

  PGDetalhePage({required this.pg});

  @override
  _PGDetalhePageState createState() => _PGDetalhePageState();
}


// ==========================================
// STATE
// ==========================================

class _PGDetalhePageState extends State<PGDetalhePage> {

  List<Presenca> presencas = [];
  List<String> visitantes = [];

  // ==========================================
  // INIT
  // ==========================================

  @override
  void initState() {
    super.initState();
    carregarMembrosDoPG();
  }


  // ==========================================
  // CARREGAR MEMBROS
  // ==========================================

  Future carregarMembrosDoPG() async {

    final url = Uri.parse(
      "${ApiService.baseUrl}/membros_pg/${widget.pg.id}"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      setState(() {
        presencas = data.map<Presenca>((m) => Presenca(
          id: m["id"],
          nome: m["nome"],
        )).toList();
      });
    }
  }


  // ==========================================
  // SALVAR PRESENÇA
  // ==========================================

  Future salvarPresencaAPI() async {

    final url = Uri.parse("${ApiService.baseUrl}/presencas");

    final presentesIds = presencas
        .where((p) => p.presente)
        .map((p) => p.id)
        .toList();

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "pg_id": widget.pg.id,
        "presentes": presentesIds,
        "visitantes": visitantes
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.statusCode == 200
              ? "Presença salva com sucesso!"
              : "Erro ao salvar presença",
        ),
      ),
    );
  }


  // ==========================================
  // VINCULAR MEMBRO
  // ==========================================

  Future vincularMembro(int membroId) async {

    final url = Uri.parse("${ApiService.baseUrl}/vincular_membro_pg");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "membro_id": membroId,
        "pg_id": widget.pg.id
      }),
    );
  }


  // ==========================================
  // ADICIONAR MEMBRO
  // ==========================================

  void adicionarMembro() async {

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelecionarMembrosPGPage(),
      ),
    );

    if (resultado != null) {

      for (var m in resultado) {

        bool jaExiste = presencas.any((p) => p.id == m["id"]);

        if (!jaExiste) {

          await vincularMembro(m["id"]);

          setState(() {
            presencas.add(
              Presenca(
                id: m["id"],
                nome: m["nome"],
              ),
            );
          });

        }
      }
    }
  }


  // ==========================================
  // ADICIONAR VISITANTE
  // ==========================================

  void adicionarVisitante() {

    TextEditingController nome = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Adicionar visitante"),
          content: TextField(
            controller: nome,
            decoration: InputDecoration(labelText: "Nome"),
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  visitantes.add(nome.text);
                });
                Navigator.pop(context);
              },
              child: Text("Adicionar"),
            ),

          ],
        );
      },
    );
  }


  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.pg.nome),

        actions: [

          // 📊 Frequência
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FrequenciaPGPage(
                    pgId: widget.pg.id,
                  ),
                ),
              );
            },
          ),

          // 🚨 Alerta
          IconButton(
            icon: Icon(Icons.warning, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertaPGPage(
                    pgId: widget.pg.id,
                  ),
                ),
              );
            },
          ),

        ],
      ),

      body: Column(
        children: [

          // ================= MEMBROS =================
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "Membros",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                ElevatedButton.icon(
                  onPressed: adicionarMembro,
                  icon: Icon(Icons.person_add),
                  label: Text("Adicionar"),
                ),

              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: presencas.length,
              itemBuilder: (context, index) {

                final membro = presencas[index];

                return CheckboxListTile(
                  title: Text(membro.nome),
                  value: membro.presente,
                  onChanged: (valor) {
                    setState(() {
                      membro.presente = valor!;
                    });
                  },
                );
              },
            ),
          ),

          Divider(),

          // ================= VISITANTES =================
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "Visitantes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                ElevatedButton.icon(
                  onPressed: adicionarVisitante,
                  icon: Icon(Icons.person_add_alt),
                  label: Text("Adicionar"),
                ),

              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: visitantes.length,
              itemBuilder: (context, index) {

                return ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text(visitantes[index]),
                );
              },
            ),
          ),

          // ================= BOTÃO SALVAR =================
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton.icon(
              onPressed: salvarPresencaAPI,
              icon: Icon(Icons.save),
              label: Text("Salvar Presença"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          )

        ],
      ),
    );
  }
}