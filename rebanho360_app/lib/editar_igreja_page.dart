import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'api_service.dart';

class EditarIgrejaPage extends StatefulWidget {

  final Map igreja;

  EditarIgrejaPage({required this.igreja});

  @override
  _EditarIgrejaPageState createState() => _EditarIgrejaPageState();
}

class _EditarIgrejaPageState extends State<EditarIgrejaPage> {

  late TextEditingController razao;
  late TextEditingController fantasia;
  late TextEditingController cnpj;
  late TextEditingController endereco;
  late TextEditingController cidade;
  late TextEditingController telefone;
  late TextEditingController email;
  late TextEditingController site;
  late TextEditingController pastor;

  String tipo = "SEDE";
  bool salvando = false;

  final cnpjMask = MaskTextInputFormatter(mask: '##.###.###/####-##');
  final telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');

  @override
  void initState() {
    super.initState();

    final i = widget.igreja;

    razao = TextEditingController(text: i["razao_social"]);
    fantasia = TextEditingController(text: i["nome_fantasia"]);
    cnpj = TextEditingController(text: i["cnpj"]);
    endereco = TextEditingController(text: i["endereco"]);
    cidade = TextEditingController(text: i["cidade"]);
    telefone = TextEditingController(text: i["telefone"]);
    email = TextEditingController(text: i["email"]);
    site = TextEditingController(text: i["site"]);
    pastor = TextEditingController(text: i["pastor"]);

    tipo = i["tipo"] ?? "SEDE";
  }

  Future salvar() async {

    setState(() => salvando = true);

    try {

      final res = await ApiService.put(
        "/igrejas/${widget.igreja["id"]}",
        jsonEncode({
          "razao_social": razao.text,
          "nome_fantasia": fantasia.text,
          "cnpj": cnpj.text,
          "endereco": endereco.text,
          "cidade": cidade.text,
          "telefone": telefone.text,
          "email": email.text,
          "site": site.text,
          "pastor": pastor.text,
          "tipo": tipo
        }),
      );

      if (res.statusCode == 200) {
        Navigator.pop(context, true);
      }

    } catch (e) {
      print(e);
    } finally {
      setState(() => salvando = false);
    }
  }

  Widget campo(String label, TextEditingController controller,
      {TextInputFormatter? mask}) {

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
      appBar: AppBar(title: Text("Editar Igreja")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            campo("Razão Social", razao),
            campo("Nome Fantasia", fantasia),
            campo("CNPJ", cnpj, mask: cnpjMask),
            campo("Endereço", endereco),
            campo("Cidade", cidade),
            campo("Telefone", telefone, mask: telefoneMask),
            campo("Email", email),
            campo("Site", site),
            campo("Pastor", pastor),

            DropdownButtonFormField(
              value: tipo,
              items: ["SEDE", "FILIAL"]
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => tipo = v.toString()),
              decoration: InputDecoration(labelText: "Tipo"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: salvando ? null : salvar,
              child: salvando
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Salvar"),
            )
          ],
        ),
      ),
    );
  }
}

