import 'package:flutter/material.dart';
import 'dart:convert';

import 'cadastro_familia_page.dart';
import 'api_service.dart';

class FamiliasPage extends StatefulWidget {
  @override
  _FamiliasPageState createState() => _FamiliasPageState();
}

class _FamiliasPageState extends State<FamiliasPage> {

  List familias = [];

  // ==========================
  // CARREGAR DO BACKEND
  // ==========================
  Future carregar() async {

    final res = await ApiService.get("/familias");

    if (res.statusCode == 200) {
      setState(() {
        familias = jsonDecode(res.body);
      });
    } else {
      print("Erro ao carregar famílias");
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

      appBar: AppBar(
        title: Text("Famílias"),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CadastroFamiliaPage(),
            ),
          );

          // 🔥 RECARREGA AO VOLTAR
          if (result == true) {
            carregar();
          }
        },
      ),

      body: familias.isEmpty
          ? Center(child: Text("Nenhuma família cadastrada"))
          : ListView.builder(

              itemCount: familias.length,

              itemBuilder: (context, index) {

                final familia = familias[index];

                return ListTile(

                  leading: Icon(Icons.family_restroom),

                  title: Text(familia["nome"] ?? ""),

                  subtitle: Text(familia["telefone"] ?? ""),

                );

              },

            ),
    );
  }
}

