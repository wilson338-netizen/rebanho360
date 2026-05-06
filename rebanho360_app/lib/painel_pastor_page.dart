import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class PainelPastorPage extends StatefulWidget {
  @override
  _PainelPastorPageState createState() => _PainelPastorPageState();
}

class _PainelPastorPageState extends State<PainelPastorPage> {

  List oracoes = [];
  List agendamentos = [];

  Future carregar() async {
    final res = await ApiService.get("/painel/atendimentos");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      setState(() {
        oracoes = data["oracoes"] ?? [];
        agendamentos = data["agendamentos"] ?? [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  // ==========================
  // RESPOSTA ORAÇÃO
  // ==========================
  void abrirResposta(int id) {

    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Responder oração"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Digite a resposta"),
          ),
          actions: [
            TextButton(
              onPressed: () async {

                await ApiService.put(
                  "/oracao/responder/$id",
                  jsonEncode({"resposta": controller.text}),
                );

                Navigator.pop(context);
                carregar();

              },
              child: Text("Enviar"),
            )
          ],
        );
      },
    );
  }

  // ==========================
  // RESPOSTA AGENDAMENTO 🔥 NOVO
  // ==========================
  void abrirRespostaAgendamento(int id) {

    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Responder agendamento"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Digite a resposta"),
          ),
          actions: [
            TextButton(
              onPressed: () async {

                await ApiService.put(
                  "/agendamento/responder/$id",
                  jsonEncode({"resposta": controller.text}),
                );

                Navigator.pop(context);
                carregar();

              },
              child: Text("Enviar"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Painel do Pastor")),

      body: ListView(
        padding: EdgeInsets.all(10),
        children: [

          // ==========================
          // ORAÇÕES
          // ==========================
          Text("🙏 Pedidos de Oração",
              style: TextStyle(fontWeight: FontWeight.bold)),

          ...oracoes.map((o) {
            return Card(
              child: ListTile(
                title: Text(o["nome"] ?? ""),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o["pedido"] ?? ""),
                    if ((o["resposta"] ?? "").toString().isNotEmpty)
                      Text("Resposta: ${o["resposta"]}",
                          style: TextStyle(color: Colors.green)),
                  ],
                ),
                trailing: Icon(Icons.reply),
                onTap: () => abrirResposta(o["id"]),
              ),
            );
          }).toList(),

          SizedBox(height: 20),

          // ==========================
          // AGENDAMENTOS
          // ==========================
          Text("📅 Agendamentos",
              style: TextStyle(fontWeight: FontWeight.bold)),

          ...agendamentos.map((a) {
            return Card(
              child: ListTile(
                title: Text(a["nome"] ?? ""),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a["data"] ?? ""),
                    if ((a["resposta"] ?? "").toString().isNotEmpty)
                      Text("Resposta: ${a["resposta"]}",
                          style: TextStyle(color: Colors.green)),
                  ],
                ),
                trailing: Icon(Icons.reply), // 🔥 AGORA TEM BOTÃO
                onTap: () => abrirRespostaAgendamento(a["id"]), // 🔥 NOVO
              ),
            );
          }).toList(),

        ],
      ),
    );
  }
}

