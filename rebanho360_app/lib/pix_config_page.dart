import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class PixConfigPage extends StatefulWidget {
  @override
  _PixConfigPageState createState() => _PixConfigPageState();
}

class _PixConfigPageState extends State<PixConfigPage> {

  final chave = TextEditingController();
  final nome = TextEditingController();
  final cidade = TextEditingController();

  Future salvar() async {

    final res = await ApiService.put(
      "/igreja/pix",
      jsonEncode({
        "pix_chave": chave.text,
        "pix_nome": nome.text,
        "pix_cidade": cidade.text,
      }),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PIX salvo com sucesso")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Configurar PIX")),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: chave,
              decoration: InputDecoration(labelText: "Chave PIX"),
            ),

            TextField(
              controller: nome,
              decoration: InputDecoration(labelText: "Nome"),
            ),

            TextField(
              controller: cidade,
              decoration: InputDecoration(labelText: "Cidade"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: salvar,
              child: Text("Salvar"),
            )
          ],
        ),
      ),
    );
  }
}

