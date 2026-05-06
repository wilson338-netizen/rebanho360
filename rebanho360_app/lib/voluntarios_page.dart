import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'escala_page.dart';

class VoluntariosPage extends StatefulWidget {
  final int? eventoId;

  VoluntariosPage({this.eventoId});

  @override
  _VoluntariosPageState createState() => _VoluntariosPageState();
}

class _VoluntariosPageState extends State<VoluntariosPage> {

  List eventos = [];
  List voluntarios = [];
  List membros = [];

  int? membroSelecionado;
  String? funcao;

  @override
  void initState() {
    super.initState();

    if (widget.eventoId == null) {
      carregarEventos();
    } else {
      carregarVoluntarios();
      carregarMembros();
    }
  }

  // ==========================
  // EVENTOS
  // ==========================
  Future carregarEventos() async {
    final res = await ApiService.get("/eventos");

    if (res.statusCode == 200) {
      setState(() {
        eventos = jsonDecode(res.body);
      });
    }
  }

  // ==========================
  // VOLUNTÁRIOS
  // ==========================
  Future carregarVoluntarios() async {
    final res = await ApiService.get("/voluntarios");

    if (res.statusCode == 200) {
      setState(() {
        voluntarios = jsonDecode(res.body);
      });
    }
  }

  // ==========================
  // MEMBROS
  // ==========================
  Future carregarMembros() async {
    final res = await ApiService.get("/membros");

    if (res.statusCode == 200) {
      setState(() {
        membros = jsonDecode(res.body);
      });
    }
  }

  // ==========================
  // INSCRIÇÃO
  // ==========================
  Future inscrever() async {

    if (membroSelecionado == null || funcao == null) return;

    await ApiService.post(
      "/voluntarios",
      jsonEncode({
        "membro_id": membroSelecionado,
        "evento_id": widget.eventoId,
        "funcao": funcao
      }),
    );

    carregarVoluntarios();
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {

    // 🔥 LISTA DE EVENTOS
    if (widget.eventoId == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Eventos")),
        body: eventos.isEmpty
            ? Center(child: Text("Nenhum evento cadastrado"))
            : ListView.builder(
                itemCount: eventos.length,
                itemBuilder: (context, index) {

                  final evento = eventos[index];

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: Icon(Icons.event),
                      title: Text(evento["titulo"] ?? ""),
                      subtitle: Text(evento["data_evento"] ?? ""),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VoluntariosPage(
                              eventoId: evento["id"],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      );
    }

    // 🔥 VOLUNTÁRIOS
    return Scaffold(
      appBar: AppBar(
        title: Text("Voluntários"),
        actions: [
          IconButton(
            icon: Icon(Icons.auto_awesome),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EscalaPage(
                    eventoId: widget.eventoId!,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [

          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [

                DropdownButtonFormField<int>(
                  hint: Text("Selecionar membro"),
                  value: membroSelecionado,
                  items: membros.map<DropdownMenuItem<int>>((m) {
                    return DropdownMenuItem(
                      value: m["id"],
                      child: Text(m["nome"] ?? ""),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => membroSelecionado = v);
                  },
                ),

                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  hint: Text("Função"),
                  value: funcao,
                  items: ["Recepção", "Louvor", "Mídia", "Intercessão"]
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => funcao = v!);
                  },
                ),

                SizedBox(height: 10),

                ElevatedButton(
                  onPressed: inscrever,
                  child: Text("Inscrever"),
                ),

              ],
            ),
          ),

          Divider(),

          Expanded(
            child: voluntarios.isEmpty
                ? Center(child: Text("Nenhum voluntário"))
                : ListView.builder(
                    itemCount: voluntarios.length,
                    itemBuilder: (context, index) {

                      final item = voluntarios[index];

                      return Card(
                        child: ListTile(
                          title: Text(item["nome"] ?? ""),
                          subtitle: Text(
                            "Função: ${item["funcao"] ?? ""} | ${item["status"] ?? ""}",
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

