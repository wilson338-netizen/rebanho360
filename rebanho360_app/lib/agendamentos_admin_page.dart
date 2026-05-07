import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendamentosAdminPage extends StatefulWidget {
  @override
  _AgendamentosAdminPageState createState() => _AgendamentosAdminPageState();
}

class _AgendamentosAdminPageState extends State<AgendamentosAdminPage> {

  List dados = [];

  Future carregar() async {
    final res = await http.get(
      Uri.parse("${ApiService.baseUrl}/agendamentos"),
    );

    setState(() {
      dados = jsonDecode(res.body);
    });
  }

  Future atualizar(int id) async {
    await http.put(
      Uri.parse("${ApiService.baseUrl}/agendamentos/$id?status=atendido"),
    );

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
      appBar: AppBar(title: Text("Agendamentos")),

      body: ListView.builder(
        itemCount: dados.length,
        itemBuilder: (context, i) {

          final item = dados[i];

          return Card(
            child: ListTile(
              title: Text(item["nome"]),
              subtitle: Text(
                  "${item["pedido"]}\nData: ${item["data"]}\nStatus: ${item["status"]}"),
              trailing: item["status"] == "pendente"
                  ? ElevatedButton(
                      onPressed: () => atualizar(item["id"]),
                      child: Text("Atender"),
                    )
                  : Icon(Icons.check, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}

