import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'package:flutter/services.dart';

class OfertaPage extends StatefulWidget {
  @override
  _OfertaPageState createState() => _OfertaPageState();
}

class _OfertaPageState extends State<OfertaPage> {

  TextEditingController valor = TextEditingController();

  String chavePix = "";
  String nome = "";
  String cidade = "";

  @override
  void initState() {
    super.initState();
    carregarPix();
  }

  Future carregarPix() async {

    final res = await ApiService.get("/igreja/pix");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      setState(() {
        chavePix = data["pix_chave"] ?? "";
        nome = data["pix_nome"] ?? "";
        cidade = data["pix_cidade"] ?? "";
      });
    }
  }

  void copiarPix() {
    Clipboard.setData(ClipboardData(text: chavePix));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PIX copiado")),
    );
  }

  void gerarPix() {

    if (valor.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Digite um valor")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Oferta via PIX"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text("Valor: R\$ ${valor.text}"),
            SizedBox(height: 10),

            SelectableText(
              chavePix,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text("Nome: $nome"),
            Text("Cidade: $cidade"),

          ],
        ),
        actions: [

          TextButton(
            onPressed: copiarPix,
            child: Text("Copiar PIX"),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fechar"),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [

          TextField(
            controller: valor,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Valor"),
          ),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: gerarPix,
            child: Text("Gerar PIX"),
          ),

        ],
      ),
    );
  }
}
