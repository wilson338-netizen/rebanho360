import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  List conversas = [];

  Future carregar() async {
    final res = await ApiService.get("/chat/conversas");

    if (res.statusCode == 200) {
      if (!mounted) return;

      setState(() {
        conversas = jsonDecode(res.body);
      });
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
      appBar: AppBar(title: Text("Conversas")),

      body: conversas.isEmpty
          ? Center(child: Text("Nenhuma conversa"))
          : ListView.builder(
              itemCount: conversas.length,
              itemBuilder: (context, index) {

                final c = conversas[index];

                return ListTile(

                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),

                  title: Text(c["nome"] ?? ""),

                  subtitle: Text(
                    c["ultima_mensagem"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(
                        (c["data"] != null && c["data"].toString().length >= 16)
                            ? c["data"].toString().substring(11, 16)
                            : "",
                        style: TextStyle(fontSize: 12),
                      ),

                      if ((c["nao_lidas"] ?? 0) > 0)
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            c["nao_lidas"].toString(),
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),

                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          destinatarioId: c["membro_id"],
                          nome: c["nome"],
                        ),
                      ),
                    ).then((_) => carregar()); // 🔄 atualiza ao voltar
                  },
                );
              },
            ),
    );
  }
}
