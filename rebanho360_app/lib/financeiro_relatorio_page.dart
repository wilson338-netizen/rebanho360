import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rebanho360_app/api_service.dart';

final String baseUrl = "${ApiService.baseUrl}";


class FinanceiroRelatorioPage extends StatefulWidget {
  @override
  _FinanceiroRelatorioPageState createState() =>
      _FinanceiroRelatorioPageState();
}

class _FinanceiroRelatorioPageState
    extends State<FinanceiroRelatorioPage> {

  List dados = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/financeiro/membros")
    );

    if (response.statusCode == 200) {
      setState(() {
        dados = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Relatório por Membro"),
      ),

      body: ListView.builder(
        itemCount: dados.length,
        itemBuilder: (context, index) {

          final item = dados[index];

          return ListTile(
            leading: Icon(Icons.person),
            title: Text(item["nome"]),
            subtitle: Text(
              "Lançamentos: ${item["total_lancamentos"]}"
            ),
            trailing: Text(
              "R\$ ${item["total_contribuido"]}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
