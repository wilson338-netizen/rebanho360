import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class CadastroIgrejaPage extends StatefulWidget {
  @override
  _CadastroIgrejaPageState createState() => _CadastroIgrejaPageState();
}

class _CadastroIgrejaPageState extends State<CadastroIgrejaPage> {

  final nomeIgreja = TextEditingController();
  final nomeAdmin = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();

  bool carregando = false;

  Future cadastrar() async {

    if (nomeIgreja.text.isEmpty ||
        nomeAdmin.text.isEmpty ||
        email.text.isEmpty ||
        senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    setState(() => carregando = true);

    final response = await ApiService.post(
      "/igrejas/cadastrar",
      jsonEncode({
        "nome": nomeIgreja.text,
        "nome_admin": nomeAdmin.text,
        "email": email.text,
        "senha": senha.text,
      }),
    );

    setState(() => carregando = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Igreja cadastrada com sucesso")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar Igreja")),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nomeIgreja,
              decoration: InputDecoration(labelText: "Nome da Igreja"),
            ),

            TextField(
              controller: nomeAdmin,
              decoration: InputDecoration(labelText: "Nome do Admin"),
            ),

            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: senha,
              obscureText: true,
              decoration: InputDecoration(labelText: "Senha"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: carregando ? null : cadastrar,
              child: carregando
                  ? CircularProgressIndicator()
                  : Text("Cadastrar"),
            ),

          ],
        ),
      ),
    );
  }
}

