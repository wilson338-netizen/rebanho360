import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rebanho360_app/api_service.dart';

final String baseUrl = "${ApiService.baseUrl}";


class FrequenciaPGPage extends StatefulWidget {

  final int pgId;

  FrequenciaPGPage({required this.pgId});

  @override
  _FrequenciaPGPageState createState() => _FrequenciaPGPageState();
}

class _FrequenciaPGPageState extends State<FrequenciaPGPage> {

  List dados = [];

  @override
  void initState() {
    super.initState();
    carregarFrequencia();
  }

  Future carregarFrequencia() async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/frequencia_pg/${widget.pgId}")
    );

    if (response.statusCode == 200) {
      setState(() {
        dados = jsonDecode(response.body);
      });
    }
  }

  Color corPercentual(double p) {
    if (p >= 80) return Colors.green;
    if (p >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Frequência do PG"),
      ),

      body: ListView.builder(
        itemCount: dados.length,
        itemBuilder: (context, index) {

          final item = dados[index];
          final percentual = item["percentual"].toDouble();

          return Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(item["nome"]),
              subtitle: Text(
                "Presenças: ${item["presencas"]} / ${item["total"]}"
              ),
              trailing: Text(
                "$percentual%",
                style: TextStyle(
                  color: corPercentual(percentual),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
