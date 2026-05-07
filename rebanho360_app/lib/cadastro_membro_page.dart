// ============================================
// IMPORTAÇÕES
// ============================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'data/familias_data.dart';

import 'package:rebanho360_app/api_service.dart';

final String baseUrl = "${ApiService.baseUrl}";

// ============================================
// TELA CADASTRO MEMBRO
// ============================================

class CadastroMembroPage extends StatefulWidget {
  @override
  _CadastroMembroPageState createState() => _CadastroMembroPageState();
}


// ============================================
// ESTADO DA TELA
// ============================================

class _CadastroMembroPageState extends State<CadastroMembroPage> {


// ============================================
// CONTROLLERS
// ============================================

  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final enderecoController = TextEditingController();

  String? familiaSelecionada;


// ============================================
// FOTO DO MEMBRO
// ============================================

  File? foto;

  final picker = ImagePicker();

  Future escolherFoto() async {

    final imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {

      setState(() {
        foto = File(imagem.path);
      });

    }

  }


// ============================================
// SALVAR MEMBRO
// ============================================

  Future salvar(BuildContext context) async {

    final response = await http.post(

      Uri.parse("${ApiService.baseUrl}/membros"),

      headers: {
        "Content-Type": "application/json"
      },

      body: jsonEncode({

        "nome": nomeController.text,
        "telefone": telefoneController.text,
        "endereco": enderecoController.text,
        "familia": familiaSelecionada

      }),

    );

    if (response.statusCode == 200) {

      Navigator.pop(context);

    } else {

      print(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar membro")),
      );

    }

  }


// ============================================
// INTERFACE
// ============================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Novo Membro"),
      ),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: SingleChildScrollView(

          child: Column(

            children: [

              // FOTO

              GestureDetector(

                onTap: escolherFoto,

                child: CircleAvatar(

                  radius: 50,

                  backgroundImage:
                      foto != null ? FileImage(foto!) : null,

                  child: foto == null
                      ? Icon(Icons.camera_alt, size: 40)
                      : null,

                ),

              ),

              SizedBox(height: 20),

              // NOME

              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: "Nome"),
              ),

              SizedBox(height: 20),

              // TELEFONE

              TextField(
                controller: telefoneController,
                decoration: InputDecoration(labelText: "Telefone"),
              ),

              SizedBox(height: 20),

              // ENDEREÇO

              TextField(
                controller: enderecoController,
                decoration: InputDecoration(labelText: "Endereço"),
              ),

              SizedBox(height: 20),

              // FAMÍLIA

              DropdownButtonFormField<String>(
                value: familiaSelecionada,
                decoration: InputDecoration(
                  labelText: "Família",
                ),
                items: listaFamilias.map((familia) {
                  return DropdownMenuItem(
                    value: familia.nome,
                    child: Text(familia.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    familiaSelecionada = value;
                  });
                },
              ),

              SizedBox(height: 30),

              // BOTÃO SALVAR

              ElevatedButton(
                onPressed: () {
                  salvar(context);
                },
                child: Text("Salvar"),
              ),

            ],

          ),

        ),

      ),

    );

  }

}
