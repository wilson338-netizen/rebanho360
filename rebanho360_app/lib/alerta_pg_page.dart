import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertaPGPage extends StatefulWidget {

  final int pgId;

  AlertaPGPage({required this.pgId});

  @override
  _AlertaPGPageState createState() => _AlertaPGPageState();
}

class _AlertaPGPageState extends State<AlertaPGPage> {

  List dados = [];

  @override
  void initState() {
    super.initState();
    carregarAlertas();
  }

  Future carregarAlertas() async {

    final response = await http.get(
      Uri.parse("http://localhost:8000/alerta_ausentes/${widget.pgId}")
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
        title: Text("Alerta de Ausência"),
      ),

      body: dados.isEmpty
          ? Center(child: Text("Nenhum alerta 🚀"))
          : ListView.builder(
              itemCount: dados.length,
              itemBuilder: (context, index) {

                final item = dados[index];

                return Card(
                  color: Colors.red.shade100,
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.red),
                    title: Text(item["nome"]),
                    subtitle: Text(
                      "Frequência: ${item["percentual"]}%"
                    ),
                  ),
                );
              },
            ),
    );
  }
}

