import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart'; // 🔥 USAR PADRÃO DO APP
import 'carteirinha_page.dart';

class CarteirinhasPage extends StatefulWidget {
  @override
  _CarteirinhasPageState createState() => _CarteirinhasPageState();
}

class _CarteirinhasPageState extends State<CarteirinhasPage> {

  List membros = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  // ==========================
  // CARREGAR MEMBROS
  // ==========================
  Future carregar() async {

    try {
      final res = await ApiService.get("/membros"); // 🔥 CORRIGIDO

      print("STATUS MEMBROS: ${res.statusCode}");
      print("BODY MEMBROS: ${res.body}");

      if (res.statusCode == 200) {

        final data = jsonDecode(res.body);

        setState(() {
          membros = data ?? [];
        });

      } else {
        print("Erro ao carregar membros");
      }

    } catch (e) {
      print("ERRO CARTEIRINHAS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Carteirinhas"),
      ),

      body: membros.isEmpty
          ? Center(child: Text("Nenhum membro encontrado"))
          : ListView.builder(
              itemCount: membros.length,
              itemBuilder: (context, index) {

                if (index >= membros.length) return SizedBox(); // 🔥 proteção

                final m = membros[index];

                return Card(
                  margin: EdgeInsets.all(10),

                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),

                    title: Text(m["nome"] ?? ""),

                    subtitle: Text("ID: ${m["id"] ?? ""}"),

                    trailing: ElevatedButton(
                      child: Text("Ver"),
                      onPressed: () {

                        if (m["id"] == null) return; // 🔥 proteção

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CarteirinhaPage(
                              membroId: m["id"],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

