import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class AgendamentoPage extends StatefulWidget {
  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {

  TextEditingController nome = TextEditingController();
  TextEditingController pedido = TextEditingController();
  TextEditingController data = TextEditingController();

  List agendamentos = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {
    final res = await ApiService.get("/membro/agendamentos");

    if (res.statusCode == 200) {
      setState(() {
        agendamentos = jsonDecode(res.body);
      });
    }
  }

  void enviar() async {

    if (nome.text.isEmpty || pedido.text.isEmpty || data.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    try {

      final response = await ApiService.post(
        "/agendamento",
        jsonEncode({
          "nome": nome.text,
          "pedido": pedido.text,
          "data": data.text
        }),
      );

      if (response.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pedido enviado com sucesso!")),
        );

        nome.clear();
        pedido.clear();
        data.clear();

        carregar(); // 🔥 ATUALIZA LISTA

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao enviar pedido")),
        );
      }

    } catch (e) {

      print("ERRO AGENDAMENTO: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao conectar com servidor")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Agendamento Pastoral"),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nome,
              decoration: InputDecoration(labelText: "Seu nome"),
            ),

            SizedBox(height: 15),

            TextField(
              controller: pedido,
              decoration: InputDecoration(labelText: "Pedido"),
            ),

            SizedBox(height: 15),

            TextField(
              controller: data,
              decoration: InputDecoration(
                labelText: "Data (YYYY-MM-DD)",
              ),
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enviar,
                child: Text("Enviar Pedido"),
              ),
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  ...agendamentos.map((a) {
                    return Card(
                      child: ListTile(
                        title: Text(a["data"] ?? ""),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Status: ${a["status"]}"),
                            if ((a["resposta"] ?? "").toString().isNotEmpty)
                              Text(
                                "Resposta: ${a["resposta"]}",
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
      ),
    );
  }
}

