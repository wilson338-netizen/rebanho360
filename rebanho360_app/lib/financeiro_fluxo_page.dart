import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FinanceiroFluxoPage extends StatefulWidget {
  @override
  _FinanceiroFluxoPageState createState() =>
      _FinanceiroFluxoPageState();
}

class _FinanceiroFluxoPageState
    extends State<FinanceiroFluxoPage> {

  List dados = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {

    final response = await http.get(
      Uri.parse("http://localhost:8000/financeiro/mensal")
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
        title: Text("Fluxo de Caixa"),
      ),

      body: ListView.builder(
        itemCount: dados.length,
        itemBuilder: (context, index) {

          final item = dados[index];

          return Card(
            child: ListTile(
              title: Text("Mês: ${item["mes"]}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Entradas: R\$ ${item["entradas"]}"),
                  Text("Saídas: R\$ ${item["saidas"]}"),
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
    );
  }
}
