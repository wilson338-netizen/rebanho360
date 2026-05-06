import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class DevocionalPage extends StatefulWidget {
  @override
  _DevocionalPageState createState() => _DevocionalPageState();
}

class _DevocionalPageState extends State<DevocionalPage> {

  Map dev = {};
  bool carregando = true;

  Future carregar() async {

    setState(() {
      carregando = true;
    });

    final res = await ApiService.get("/devocional/hoje");

    if (res.statusCode == 200) {
      dev = jsonDecode(res.body);
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
        title: Text("Devocional"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: carregar,
          )
        ],
      ),

      body: carregando
          ? Center(child: CircularProgressIndicator())
          : dev.isEmpty
              ? Center(
                  child: Text(
                    "Nenhum devocional disponível hoje 🙏",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(20),
                  child: ListView(
                    children: [

                      // 🔥 TÍTULO FIXO
                      Text(
                        "Devocional do Dia",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),

                      SizedBox(height: 15),

                      // 🔥 TEMA
                      Text(
                        dev["titulo"] ?? "",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      // 🔥 VERSÍCULO
                      Text(
                        dev["versiculo"] ?? "",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),

                      SizedBox(height: 20),

                      // 🔥 MENSAGEM
                      Text(
                        dev["mensagem"] ?? "",
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 30),

                      // 🔥 ORAÇÃO
                      if ((dev["oracao"] ?? "").toString().isNotEmpty) ...[
                        Text(
                          "🙏 Momento de Oração",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(dev["oracao"]),
                      ],

                    ],
                  ),
                ),
    );
  }
}

