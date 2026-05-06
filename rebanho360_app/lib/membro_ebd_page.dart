import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class MembroEBDPage extends StatefulWidget {
  @override
  _MembroEBDPageState createState() => _MembroEBDPageState();
}

class _MembroEBDPageState extends State<MembroEBDPage> {

  Map dados = {};

  Future carregar() async {
    final res = await ApiService.get("/membro/ebd");

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
      appBar: AppBar(title: Text("Minha EBD")),

      body: dados.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Turma: ${dados["turma"]}", style: TextStyle(fontSize: 18)),

                  SizedBox(height: 10),

                  Text("Professor: ${dados["professor"]}"),

                  SizedBox(height: 10),

                  Text("Lição: ${dados["licao"]}"),
SizedBox(height: 10),
Text(dados["descricao"] ?? ""),


                  Text("Frequência: ${dados["frequencia"]}%"),

                ],
              ),
            ),
    );
  }
}
