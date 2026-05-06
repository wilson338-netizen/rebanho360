import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'api_service.dart';

class NovaCongregacaoPage extends StatefulWidget {
  @override
  _NovaCongregacaoPageState createState() => _NovaCongregacaoPageState();
}

class _NovaCongregacaoPageState extends State<NovaCongregacaoPage> {

  final nome = TextEditingController();
  final endereco = TextEditingController();
  final cidade = TextEditingController();
  final estado = TextEditingController();
  final cep = TextEditingController();
  final telefone = TextEditingController();
  final email = TextEditingController();
  final dirigente = TextEditingController();
  final fundacao = TextEditingController();

  bool salvando = false;

  final cepMask = MaskTextInputFormatter(mask: '#####-###');
  final telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');

  Future salvar() async {

    setState(() => salvando = true);

    try {

      final res = await ApiService.post(
        "/congregacoes",
        jsonEncode({
          "nome": nome.text,
          "endereco": endereco.text,
          "cidade": cidade.text,
          "estado": estado.text,
          "cep": cep.text,
          "telefone": telefone.text,
          "email": email.text,
          "data_fundacao": fundacao.text,
          "dirigente": dirigente.text,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context, true);
      }

    } catch (e) {
      print(e);
    } finally {
      setState(() => salvando = false);
    }
  }

  Widget campo(String label, TextEditingController controller,
      {mask}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        inputFormatters: mask != null ? [mask] : [],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Nova Congregação")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            campo("Nome", nome),
            campo("Endereço", endereco),
            campo("Cidade", cidade),
            campo("Estado", estado),
            campo("CEP", cep, mask: cepMask),
            campo("Telefone", telefone, mask: telefoneMask),
            campo("Email", email),
            campo("Dirigente", dirigente),
            campo("Data de Fundação (YYYY-MM-DD)", fundacao),

            SizedBox(height: 20),

            TextField(
              enabled: false,
              controller: TextEditingController(text: "FILIAL"),
              decoration: InputDecoration(
                labelText: "Tipo",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: salvando ? null : salvar,
              child: salvando
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Cadastrar"),
            )
          ],
        ),
      ),
    );
  }
}
