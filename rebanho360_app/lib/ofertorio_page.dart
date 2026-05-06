import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'package:flutter/services.dart';

class OfertorioPage extends StatefulWidget {
  @override
  _OfertorioPageState createState() => _OfertorioPageState();
}

class _OfertorioPageState extends State<OfertorioPage> {

  final valor = TextEditingController();

  String chavePix = "";
  String nome = "";
  String cidade = "";

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarPix();
  }

  Future carregarPix() async {

    try {
      final res = await ApiService.get("/igreja/pix");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          chavePix = data["pix_chave"] ?? "";
          nome = data["pix_nome"] ?? "";
          cidade = data["pix_cidade"] ?? "";
          carregando = false;
        });
      }

    } catch (e) {
      print(e);
      setState(() => carregando = false);
    }
  }

  void copiarPix() {
    Clipboard.setData(ClipboardData(text: chavePix));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Chave PIX copiada")),
    );
  }

void gerarPix() async {

  if (valor.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Digite um valor")),
    );
    return;
  }

  if (chavePix.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PIX não configurado")),
    );
    return;
  }

  // 🔥 SALVA NO BANCO (NOVA PARTE)
  try {
    await ApiService.post(
      "/ofertas",
      jsonEncode({
        "valor": valor.text
      }),
    );
  } catch (e) {
    print("Erro ao registrar oferta: $e");
  }

  // 🔥 MOSTRA O PIX (JÁ EXISTIA)
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
          onPressed: () {
            Clipboard.setData(ClipboardData(text: chavePix));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("PIX copiado")),
            );
          },
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

    return Scaffold(
      appBar: AppBar(title: Text("Ofertório")),

      body: carregando
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [

                  TextField(
                    controller: valor,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Valor da Oferta",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: gerarPix,
                    child: Text("Gerar PIX"),
                  )

                ],
              ),
            ),
    );
  }
}

