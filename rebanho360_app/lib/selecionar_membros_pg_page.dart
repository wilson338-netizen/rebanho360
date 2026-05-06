import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelecionarMembrosPGPage extends StatefulWidget {
  @override
  _SelecionarMembrosPGPageState createState() => _SelecionarMembrosPGPageState();
}

class _SelecionarMembrosPGPageState extends State<SelecionarMembrosPGPage> {

  List<Map<String, dynamic>> membros = [];
  List<Map<String, dynamic>> selecionados = [];

  Future carregarMembros() async {

    final response = await http.get(
      Uri.parse("http://localhost:8000/membros")
    );

    if (response.statusCode == 200) {

      List data = json.decode(response.body);

      setState(() {
        membros = data.cast<Map<String, dynamic>>();
      });

    }

  }

  @override
  void initState() {
    super.initState();
    carregarMembros();
  }

  void toggleSelecionado(Map<String, dynamic> membro){

    setState(() {

      if(selecionados.contains(membro)){
        selecionados.remove(membro);
      } else {
        selecionados.add(membro);
      }

    });

  }

  void confirmar(){
    Navigator.pop(context, selecionados);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Selecionar Membros"),
      ),

      body: ListView.builder(

        itemCount: membros.length,

        itemBuilder: (context, index){

          final membro = membros[index];
          final selecionado = selecionados.contains(membro);

          return CheckboxListTile(

            title: Text(membro["nome"]),
            subtitle: Text(membro["telefone"] ?? ""),

            value: selecionado,

            onChanged: (valor){
              toggleSelecionado(membro);
            },

          );

        },

      ),

      floatingActionButton: FloatingActionButton(
        onPressed: confirmar,
        child: Icon(Icons.check),
      ),

    );

  }
}
