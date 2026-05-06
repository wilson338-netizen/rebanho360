import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'api_service.dart';

class EditarCongregacaoPage extends StatefulWidget {
  final Map congregacao;

  const EditarCongregacaoPage({required this.congregacao});

  @override
  _EditarCongregacaoPageState createState() => _EditarCongregacaoPageState();
}

class _EditarCongregacaoPageState extends State<EditarCongregacaoPage> {

  late TextEditingController nome;
  late TextEditingController endereco;
  late TextEditingController cidade;
  late TextEditingController estado;
  late TextEditingController cep;
  late TextEditingController telefone;
  late TextEditingController email;
  late TextEditingController dirigente;
  late TextEditingController fundacao;

  bool salvando = false;

  final cepMask = MaskTextInputFormatter(mask: '#####-###');
  final telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');

  final dataMask = MaskTextInputFormatter(
    mask: '####-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();

    final c = widget.congregacao;

    nome = TextEditingController(text: c["nome"] ?? "");
    endereco = TextEditingController(text: c["endereco"] ?? "");
    cidade = TextEditingController(text: c["cidade"] ?? "");
    estado = TextEditingController(text: c["estado"] ?? "");
    cep = TextEditingController(text: c["cep"] ?? "");
    telefone = TextEditingController(text: c["telefone"] ?? "");
    email = TextEditingController(text: c["email"] ?? "");
    dirigente = TextEditingController(text: c["dirigente"] ?? "");
    fundacao = TextEditingController(
      text: c["data_fundacao"] != null
          ? c["data_fundacao"].toString().substring(0, 10)
          : "",
    );
  }

  Future salvar() async {

    setState(() => salvando = true);

    try {

      final res = await ApiService.put(
        "/congregacoes/${widget.congregacao["id"]}",
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

      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Atualizado com sucesso")),
        );

        Navigator.pop(context, true);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: ${res.body}")),
        );
      }

    } catch (e) {

      print("ERRO: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão")),
      );

    } finally {
      setState(() => salvando = false);
    }
  }

  Widget campo(String label, TextEditingController controller,
      {MaskTextInputFormatter? mask, TextInputType? tipo}) {

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        inputFormatters: mask != null ? [mask] : [],
        keyboardType: tipo,
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
      appBar: AppBar(title: Text("Editar Congregação")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            campo("Nome", nome),
            campo("Endereço", endereco),
            campo("Cidade", cidade),
            campo("Estado", estado),
            campo("CEP", cep, mask: cepMask, tipo: TextInputType.number),
            campo("Telefone", telefone, mask: telefoneMask, tipo: TextInputType.number),
            campo("Email", email),
            campo("Dirigente", dirigente),

            campo(
              "Data de Fundação (YYYY-MM-DD)",
              fundacao,
              mask: dataMask,
              tipo: TextInputType.number,
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: salvando ? null : salvar,
              child: salvando
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text("Salvar"),
            )
          ],
        ),
      ),
    );
  }
}

