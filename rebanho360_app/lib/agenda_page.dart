import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'voluntarios_page.dart';

class AgendaPage extends StatefulWidget {
  final String tipoUsuario;

  AgendaPage({required this.tipoUsuario});

  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {

  List eventos = [];

  @override
  void initState() {
    super.initState();
    carregarEventos();
  }

  Future carregarEventos() async {
    try {
      final response = await ApiService.get("/eventos");

      if (response.statusCode == 200) {
        setState(() {
          eventos = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Erro eventos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Agenda"),

        actions: [
          if (widget.tipoUsuario == "admin" || widget.tipoUsuario == "pastor")
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                TextEditingController titulo = TextEditingController();
                TextEditingController data = TextEditingController();

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Novo Evento"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titulo,
                          decoration: InputDecoration(labelText: "Título"),
                        ),
                        TextField(
                          controller: data,
                          decoration: InputDecoration(labelText: "Data"),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () async {

                          final res = await ApiService.post(
                            "/eventos",
                            jsonEncode({
                              "titulo": titulo.text,
                              "descricao": "Evento da igreja",
                              "data": data.text
                            }),
                          );

                          print("STATUS EVENTO: ${res.statusCode}");
                          print("BODY EVENTO: ${res.body}");

                          Navigator.pop(context);
                          carregarEventos();
                        },
                        child: Text("Salvar"),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),

      body: eventos.isEmpty
          ? Center(child: Text("Nenhum evento cadastrado"))
          : ListView.builder(
              itemCount: eventos.length,
              itemBuilder: (context, index) {

                final item = eventos[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.event),

                    title: Text(item["titulo"] ?? ""),
                    subtitle: Text(item["data_evento"] ?? ""),

                    // 🔥 AQUI É O SEGREDO
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoluntariosPage(
                            eventoId: item["id"],
                          ),
                        ),
                      );
                    },

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "editar") {
                          print("Editar evento");
                        }
                        if (value == "excluir") {
                          print("Excluir evento");
                        }
                      },
                      itemBuilder: (context) {
                        if (widget.tipoUsuario == "admin" || widget.tipoUsuario == "pastor") {
                          return [
                            PopupMenuItem(value: "editar", child: Text("Editar")),
                            PopupMenuItem(value: "excluir", child: Text("Excluir")),
                          ];
                        }
                        return [];
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
