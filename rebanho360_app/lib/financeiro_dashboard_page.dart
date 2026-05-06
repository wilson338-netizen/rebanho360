import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FinanceiroDashboardPage extends StatefulWidget {
  @override
  _FinanceiroDashboardPageState createState() =>
      _FinanceiroDashboardPageState();
}

class _FinanceiroDashboardPageState
    extends State<FinanceiroDashboardPage> {

  Map resumo = {};
  List dados = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {

    final res1 = await http.get(
      Uri.parse("http://localhost:8000/financeiro/resumo"),
    );

    final res2 = await http.get(
      Uri.parse("http://localhost:8000/financeiro/mensal"),
    );

    if (res1.statusCode == 200 && res2.statusCode == 200) {
      setState(() {
        resumo = jsonDecode(res1.body);
        dados = jsonDecode(res2.body);
      });
    }
  }

  Widget card(String titulo, dynamic valor, Color cor) {
    return Expanded(
      child: Card(
        color: cor,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(titulo,
                  style: TextStyle(color: Colors.white)),
              SizedBox(height: 10),
              Text(
                "R\$ $valor",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Financeiro"),
      ),
      body: Column(
        children: [

          // 🔥 CARDS
          Row(
            children: [
              card("Entradas", resumo["entradas"] ?? 0, Colors.green),
              card("Saídas", resumo["saidas"] ?? 0, Colors.red),
              card("Saldo", resumo["saldo"] ?? 0, Colors.blue),
            ],
          ),

          Divider(),

          // 🔥 LISTA MENSAL
          Expanded(
            child: ListView.builder(
              itemCount: dados.length,
              itemBuilder: (context, index) {

                final item = dados[index];

                return Card(
                  child: ListTile(
                    title: Text("Mês: ${item["mes"]}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Entradas: ${item["entradas"]}"),
                        Text("Saídas: ${item["saidas"]}"),
                        Text("Dízimos: ${item["dizimos"]}"),
                        Text("Ofertas: ${item["ofertas"]}"),
                      ],
                    ),
                    trailing: Text(
                      "R\$ ${item["saldo"]}",
                      style: TextStyle(
                        color: item["saldo"] >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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
