import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class LeituraPage extends StatefulWidget {
  @override
  _LeituraPageState createState() => _LeituraPageState();
}

class _LeituraPageState extends State<LeituraPage> {

  Map leitura = {};
  int streak = 0;

  Future carregar() async {

    final res = await ApiService.get("/leitura/hoje");
    final resStreak = await ApiService.get("/leitura/streak");

    if (res.statusCode == 200) {
      leitura = jsonDecode(res.body);
    }

    if (resStreak.statusCode == 200) {
      streak = jsonDecode(resStreak.body)["streak"];
    }

    setState(() {});
  }

  List medalhas = [];

Future carregarMedalhas() async {
  final res = await ApiService.get("/leitura/medalhas");

  if (res.statusCode == 200) {
    medalhas = jsonDecode(res.body);
  }
}


  Future concluir() async {
    await ApiService.post("/leitura/concluir", jsonEncode({}));

    carregar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Leitura concluída!")),
    );
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Leitura Bíblica")),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            // 🔥 STREAK
            Text("🔥 Sequência: $streak dias",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            Text("Dia ${leitura["dia"] ?? ""}",
                style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),

            Text(leitura["titulo"] ?? "",
                style: TextStyle(fontWeight: FontWeight.bold)),

            SizedBox(height: 10),

            Text(leitura["leitura"] ?? ""),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: concluir,
              child: Text("Marcar como Lido"),
            )

          ],
        ),
      ),
    );
  }
}

