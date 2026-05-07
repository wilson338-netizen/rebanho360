import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IAPastoralPage extends StatefulWidget {
  @override
  _IAPastoralPageState createState() => _IAPastoralPageState();
}

class _IAPastoralPageState extends State<IAPastoralPage> {

  Map dados = {};

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/ia_pastoral")
    );

    if (response.statusCode == 200) {
      setState(() {
        dados = jsonDecode(response.body);
      });
    }
  }

  Widget bloco(String titulo, List lista) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        ...lista.map<Widget>((e) => Text("• $e")).toList(),
        SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("IA Pastoral"),
      ),

      body: dados.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [

                  Text(
                    dados["tema"],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "📖 ${dados["versiculo"]}",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),

                  SizedBox(height: 20),

                  bloco("🔥 Mensagem", dados["mensagem"]),
                  bloco("📚 Estrutura", dados["estrutura"]),
                  bloco("🙏 Aplicação", dados["aplicacao"]),

                ],
              ),
            ),
    );
  }
}
