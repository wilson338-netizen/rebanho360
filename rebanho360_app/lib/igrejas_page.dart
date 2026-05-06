import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'api_service.dart';
import 'editar_igreja_page.dart'; // 🔥 IMPORT QUE FALTAVA

class IgrejasPage extends StatefulWidget {
  @override
  _IgrejasPageState createState() => _IgrejasPageState();
}

class _IgrejasPageState extends State<IgrejasPage> {

  List igrejas = [];

  final razao = TextEditingController();
  final fantasia = TextEditingController();
  final cnpj = TextEditingController();
  final endereco = TextEditingController();
  final cidade = TextEditingController();
  final telefone = TextEditingController();
  final email = TextEditingController();
  final site = TextEditingController();
  final pastor = TextEditingController();

  String tipo = "SEDE";
  bool salvando = false;

  final cnpjMask = MaskTextInputFormatter(mask: '##.###.###/####-##');
  final telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');

  // ==========================
  // CARREGAR
  // ==========================
  Future carregar() async {
    final res = await ApiService.get("/igrejas");

    if (res.statusCode == 200) {
      setState(() {
        igrejas = jsonDecode(res.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  // ==========================
  // SALVAR
  // ==========================
  Future salvar() async {

    setState(() => salvando = true);

    try {

      final res = await ApiService.post(
        "/igrejas",
        jsonEncode({
          "razao_social": razao.text,
          "nome_fantasia": fantasia.text,
          "cnpj": cnpj.text,
          "endereco": endereco.text,
          "cidade": cidade.text,
          "telefone": telefone.text,
          "email": email.text,
          "site": site.text,
          "data_fundacao": "2020-01-01",
          "pastor": pastor.text,
          "tipo": tipo
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Igreja cadastrada")),
        );

        razao.clear();
        fantasia.clear();
        cnpj.clear();
        endereco.clear();
        cidade.clear();
        telefone.clear();
        email.clear();
        site.clear();
        pastor.clear();

        setState(() => tipo = "SEDE");

        carregar();
      }

    } catch (e) {
      print(e);
    } finally {
      setState(() => salvando = false);
    }
  }

  // ==========================
  // EXCLUIR
  // ==========================
  Future excluir(int id) async {

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirmar"),
        content: Text("Deseja excluir esta igreja?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Não")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Sim")),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.delete("/igrejas/$id");
      carregar();
    }
  }

  // ==========================
  // CAMPO
  // ==========================
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

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Cadastro de Igreja")),

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
                  : Text("Cadastrar"),
            ),

            SizedBox(height: 30),
            Divider(),
            Text("Igrejas Cadastradas"),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: igrejas.length,
              itemBuilder: (context, index) {

                final i = igrejas[index];

                return ListTile(
                  title: Text(i["nome_fantasia"] ?? ""),
                  subtitle: Text(i["cidade"] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarIgrejaPage(igreja: i),
                            ),
                          ).then((_) => carregar());
                        },
                      ),

                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => excluir(i["id"]),
                      ),

                    ],
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

