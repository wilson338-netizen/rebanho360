import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {

  List dados = [];

  Future carregar() async {
    final res = await ApiService.get("/leitura/ranking");

    if (res.statusCode == 200) {
      setState(() {
        dados = jsonDecode(res.body);
      });
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
      appBar: AppBar(title: Text("Ranking Espiritual")),

      body: dados.isEmpty
          ? Center(child: Text("Nenhum dado ainda"))
          : ListView.builder(
              itemCount: dados.length,
              itemBuilder: (_, i) {

                final m = dados[i];

                return Card(
                  child: ListTile(
                    leading: Text("#${i + 1}"),
                    title: Text(m["nome"] ?? ""),
                    trailing: Text("${m["total"] ?? 0} dias"),
                  ),
                );
              },
            ),
    );
  }
}

