import 'package:flutter/material.dart';
import 'dart:convert';

import 'editar_membro_page.dart';
import 'membro_create_page.dart';
import 'api_service.dart';
import 'chat_page.dart';

class MembrosPage extends StatefulWidget {
  @override
  _MembrosPageState createState() => _MembrosPageState();
}

class _MembrosPageState extends State<MembrosPage> {

  List membros = [];
  List filtrados = [];

  String busca = "";
  bool loading = true;

  // ==========================
  // CARREGAR
  // ==========================
  Future carregar() async {

    setState(() => loading = true);

    final res = await ApiService.get("/membros");

    if (res.statusCode == 200) {

      if (!mounted) return;

      membros = jsonDecode(res.body);
      aplicarFiltro();

    } else {
      print("Erro ao carregar membros: ${res.body}");
    }

    setState(() => loading = false);
  }

  // ==========================
  // FILTRO
  // ==========================
  void aplicarFiltro() {

    setState(() {
      filtrados = membros.where((m) {
        final nome = (m["nome"] ?? "").toLowerCase();
        return nome.contains(busca.toLowerCase());
      }).toList();
    });
  }

  // ==========================
  // EXCLUIR
  // ==========================
  Future excluir(int id) async {

    final confirmar = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirmar exclusão"),
        content: Text("Deseja excluir este membro?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text("Excluir"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final res = await ApiService.delete("/membros/$id");

    if (res.statusCode == 200) {
      carregar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao excluir")),
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
        title: Text("Membros"),
        actions: [

          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {

              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MembroCreatePage()),
              );

              if (result == true) {
                carregar();
              }
            },
          )

        ],
      ),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // 🔍 BUSCA
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Buscar por nome...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      busca = v;
                      aplicarFiltro();
                    },
                  ),
                ),

                // 📋 LISTA
                Expanded(
                  child: filtrados.isEmpty
                      ? Center(child: Text("Nenhum membro encontrado"))
                      : ListView.builder(
                          itemCount: filtrados.length,
                          itemBuilder: (context, index) {

                            final m = filtrados[index];

                            final nome = m["nome"] ?? "";
                            final congregacao = m["congregacao"] ?? "Sede";
                            final segmento = m["segmento"] ?? "Não definido";

                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              elevation: 3,
                              child: ListTile(

                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: (m["foto"] != null &&
                                          m["foto"].toString().startsWith("http"))
                                      ? NetworkImage(m["foto"])
                                      : null,
                                  child: (m["foto"] == null || m["foto"] == "")
                                      ? Icon(Icons.person)
                                      : null,
                                ),

                                title: Text(nome),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Unidade: $congregacao"),
                                    Text("Segmento: $segmento"),
                                  ],
                                ),

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    IconButton(
                                      icon: Icon(Icons.chat, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatPage(
                                              destinatarioId: m["id"],
                                              nome: nome,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.orange),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditarMembroPage(membro: m),
                                          ),
                                        ).then((_) => carregar());
                                      },
                                    ),

                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => excluir(m["id"]),
                                    ),

                                  ],
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

