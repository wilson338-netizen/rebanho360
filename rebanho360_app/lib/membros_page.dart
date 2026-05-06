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

  // ==========================
  // CARREGAR
  // ==========================
  Future carregar() async {

    final res = await ApiService.get("/membros");

    if (res.statusCode == 200) {

      if (!mounted) return;

      membros = jsonDecode(res.body);
      aplicarFiltro();

    } else {
      print("Erro ao carregar membros: ${res.body}");
    }
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
    await ApiService.delete("/membros/$id");
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

      body: Column(
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
                      final congregacao = m["congregacao"] ?? "";
                      final segmento = m["segmento"] ?? "Não definido";

                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(

                          // FOTO
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

                          // NOME
                          title: Text(nome),

                          // INFORMAÇÕES
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Unidade: $congregacao"),
                              Text("Segmento: $segmento"),
                            ],
                          ),

                          // AÇÕES
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // CHAT
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

                              // EDITAR
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

                              // EXCLUIR
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

