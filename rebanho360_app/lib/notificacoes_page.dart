import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class NotificacoesPage extends StatefulWidget {
  @override
  _NotificacoesPageState createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {

  List dados = [];
  bool carregando = true;

  Future carregar() async {

    setState(() {
      carregando = true;
    });

    final res = await ApiService.get("/notificacoes");

    if (res.statusCode == 200) {
      dados = jsonDecode(res.body);
    }

    setState(() {
      carregando = false;
    });
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
        title: Text("Notificações"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: carregar,
          )
        ],
      ),

      body: carregando
          ? Center(child: CircularProgressIndicator())
          : dados.isEmpty
              ? Center(
                  child: Text("Nenhuma notificação"),
                )
              : ListView.builder(
                  itemCount: dados.length,
                  itemBuilder: (_, i) {

                    final n = dados[i];

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text(n["mensagem"] ?? ""),
                        subtitle: Text(n["data"] ?? ""),
                      ),
                    );
                  },
                ),
    );
  }
}

