import 'package:flutter/material.dart';
import 'dart:convert';

import 'nova_congregacao_page.dart';
import 'editar_congregacao_page.dart';
import 'api_service.dart';

class CongregacoesPage extends StatefulWidget {
  @override
  _CongregacoesPageState createState() => _CongregacoesPageState();
}

class _CongregacoesPageState extends State<CongregacoesPage> {

  List congregacoes = [];
  bool loading = true;

  // ==========================
  // CARREGAR
  // ==========================
  Future carregar() async {

    setState(() {
      loading = true;
    });

    try {

      final res = await ApiService.get("/congregacoes");

      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.statusCode == 200) {

        setState(() {
          congregacoes = jsonDecode(res.body);
          loading = false;
        });

      } else {

        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar congregações")),
        );
      }

    } catch (e) {

      setState(() => loading = false);

      print("ERRO: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão")),
      );
    }
  }

  // ==========================
  // EXCLUIR
  // ==========================
  Future excluir(int id) async {

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirmar"),
        content: Text("Deseja excluir esta congregação?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Não"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Sim"),
          ),
        ],
      ),
    );

    if (confirm == true) {

      final res = await ApiService.delete("/congregacoes/$id");

      print("DELETE STATUS: ${res.statusCode}");
      print("DELETE BODY: ${res.body}");

      if (res.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Congregação excluída com sucesso")),
        );

        carregar();

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao excluir")),
        );
      }
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
      appBar: AppBar(title: Text("Congregações")),

      // BOTÃO +
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NovaCongregacaoPage()),
          ).then((_) => carregar());
        },
        child: Icon(Icons.add),
      ),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : congregacoes.isEmpty
              ? Center(child: Text("Nenhuma congregação cadastrada"))
              : ListView.builder(
                  itemCount: congregacoes.length,
                  itemBuilder: (context, index) {

                    final c = congregacoes[index];

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(

                        // 🔥 TAG (sempre FILIAL visualmente)
                        leading: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "FILIAL",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        title: Text(c["nome"] ?? ""),

                        // 🔥 agora mostra só a igreja (sem duplicar tipo)
                        subtitle: Text(
                          c["igreja"] ?? "",
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // EDITAR
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditarCongregacaoPage(congregacao: c),
                                  ),
                                ).then((_) => carregar());
                              },
                            ),

                            // EXCLUIR
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => excluir(c["id"]),
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

