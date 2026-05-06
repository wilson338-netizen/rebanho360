import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class DevocionalAdminPage extends StatefulWidget {
  @override
  _DevocionalAdminPageState createState() => _DevocionalAdminPageState();
}

class _DevocionalAdminPageState extends State<DevocionalAdminPage> {

  final titulo = TextEditingController();
  final versiculo = TextEditingController();
  final mensagem = TextEditingController();
  final oracao = TextEditingController();

  Future salvar() async {

   await ApiService.post(
  "/devocional",
  jsonEncode({
    "data": DateTime.now().toString().split(" ")[0], // 🔥 AQUI
    "titulo": titulo.text,
    "versiculo": versiculo.text,
    "mensagem": mensagem.text,
    "oracao": oracao.text,
  }),
);


    titulo.clear();
    versiculo.clear();
    mensagem.clear();
    oracao.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Devocional salvo")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Devocional Admin")),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [

            TextField(
              controller: titulo,
              decoration: InputDecoration(labelText: "Título"),
            ),

            TextField(
              controller: versiculo,
              decoration: InputDecoration(labelText: "Versículo"),
            ),

            TextField(
              controller: mensagem,
              maxLines: 4,
              decoration: InputDecoration(labelText: "Mensagem"),
            ),

            TextField(
              controller: oracao,
              maxLines: 3,
              decoration: InputDecoration(labelText: "Oração"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: salvar,
              child: Text("Salvar"),
            ),

          ],
        ),
      ),
    );
  }
}

