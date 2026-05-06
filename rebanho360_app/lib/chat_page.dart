import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class ChatPage extends StatefulWidget {
  final int destinatarioId;
  final String nome;

  ChatPage({required this.destinatarioId, required this.nome});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  List mensagens = [];
  TextEditingController msg = TextEditingController();
  ScrollController scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    carregar();
    loop();
  }

  // 🔄 Atualização automática
  void loop() async {
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    await carregar();
    loop();
  }

  // 📥 Carregar mensagens
  Future carregar() async {

    final res = await ApiService.get("/chat/conversa/${widget.destinatarioId}");

    if (res.statusCode == 200) {

      if (!mounted) return;

      setState(() {
        mensagens = jsonDecode(res.body);
      });

      // 🔽 scroll automático
      Future.delayed(Duration(milliseconds: 200), () {
        if (scroll.hasClients) {
          scroll.jumpTo(scroll.position.maxScrollExtent);
        }
      });
    }
  }

  // 📤 Enviar mensagem
  Future enviar() async {

    if (msg.text.isEmpty) return;

    await ApiService.post(
      "/chat/enviar",
      jsonEncode({
        "destinatario": widget.destinatarioId,
        "mensagem": msg.text
      }),
    );

    msg.clear();
    carregar();
  }

  // 🔍 identificar se é do usuário
  bool isEu(m) {
    return m["fk_remetente"] == 1; // 🔥 depois vamos melhorar com token
  }

  // 💬 bolha estilo WhatsApp
  Widget bolha(m) {

    final eu = isEu(m);

    return Align(
      alignment: eu ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: eu ? Colors.green[300] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(m["mensagem"] ?? ""),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nome),
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView(
              controller: scroll,
              padding: EdgeInsets.all(10),
              children: mensagens.map((m) => bolha(m)).toList(),
            ),
          ),

          Row(
            children: [

              Expanded(
                child: TextField(
                  controller: msg,
                  decoration: InputDecoration(
                    hintText: "Digite uma mensagem",
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ),

              IconButton(
                icon: Icon(Icons.send),
                onPressed: enviar,
              )

            ],
          )

        ],
      ),
    );
  }
}

