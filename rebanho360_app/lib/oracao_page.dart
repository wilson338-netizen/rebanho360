import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class OracaoPage extends StatefulWidget {
  @override
  _OracaoPageState createState() => _OracaoPageState();
}

class _OracaoPageState extends State<OracaoPage> {

  final TextEditingController pedido = TextEditingController();
  List oracoes = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {
    final res = await ApiService.get("/membro/oracoes");

    if (res.statusCode == 200) {
      setState(() {
        oracoes = jsonDecode(res.body);
      });
    }
  }

  void enviar(BuildContext context) async {

    if (pedido.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Digite um pedido")),
      );
      return;
    }

    try {

      final response = await ApiService.post(
        "/oracao",
        jsonEncode({
          "pedido": pedido.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pedido enviado")),
        );
        pedido.clear();
        carregar(); // 🔥 ATUALIZA LISTA
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao enviar pedido")),
        );
      }

    } catch (e) {
      print("ERRO ORACAO: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [

          TextField(
            controller: pedido,
            decoration: InputDecoration(labelText: "Pedido de oração"),
          ),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => enviar(context),
            child: Text("Enviar"),
          ),

          SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: [
                ...oracoes.map((o) {
                  return Card(
                    child: ListTile(
                      title: Text(o["pedido"] ?? ""),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Status: ${o["status"]}"),
                          if ((o["resposta"] ?? "").toString().isNotEmpty)
                            Text(
                              "Resposta: ${o["resposta"]}",
                              style: TextStyle(color: Colors.green),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

