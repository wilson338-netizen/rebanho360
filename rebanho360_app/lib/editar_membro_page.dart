// ==========================================
// EDITAR MEMBRO (COM TURMA EBD)
// ==========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'api_service.dart';

class EditarMembroPage extends StatefulWidget {
  final Map membro;

  EditarMembroPage({required this.membro});

  @override
  _EditarMembroPageState createState() => _EditarMembroPageState();
}

class _EditarMembroPageState extends State<EditarMembroPage> {

  final nome = TextEditingController();
  final telefone = TextEditingController();
  final endereco = TextEditingController();
  final bairro = TextEditingController();
  final cep = TextEditingController();
  final municipio = TextEditingController();
  final estado = TextEditingController();
  final email = TextEditingController();

  DateTime? dataNascimento;

  String cargo = "Membro";

  List congregacoes = [];
  List familias = [];
  List turmas = [];

  int? congregacaoSelecionada;
  int? familiaSelecionada;
  int? turmaSelecionada;

  final telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');
  final cepMask = MaskTextInputFormatter(mask: '#####-###');

  @override
  void initState() {
    super.initState();

    final m = widget.membro;

    nome.text = m["nome"] ?? "";
    telefone.text = m["telefone"] ?? "";
    endereco.text = m["endereco"] ?? "";
    bairro.text = m["bairro"] ?? "";
    cep.text = m["cep"] ?? "";
    municipio.text = m["municipio"] ?? "";
    estado.text = m["estado"] ?? "";
    email.text = m["email"] ?? "";

    cargo = m["cargo"] ?? "Membro";

    congregacaoSelecionada = m["fk_congregacao"];
    familiaSelecionada = m["fk_familia"];
    turmaSelecionada = m["fk_turma"]; // 🔥 IMPORTANTE

    if (m["data_nascimento"] != null) {
      dataNascimento = DateTime.tryParse(m["data_nascimento"]);
    }

    carregarRelacoes();
  }

  Future carregarRelacoes() async {
    final c = await ApiService.get("/congregacoes");
    final f = await ApiService.get("/familias");
    final t = await ApiService.get("/ebd/turmas");

    if (c.statusCode == 200 && f.statusCode == 200 && t.statusCode == 200) {
      setState(() {
        congregacoes = jsonDecode(c.body);
        familias = jsonDecode(f.body);
        turmas = jsonDecode(t.body);
      });
    }
  }

  Future salvar() async {

    final res = await ApiService.put(
      "/membros/${widget.membro["id"]}",
      jsonEncode({
        "nome": nome.text,
        "telefone": telefone.text,
        "endereco": endereco.text,
        "bairro": bairro.text,
        "cep": cep.text,
        "municipio": municipio.text,
        "estado": estado.text,
        "email": email.text,
        "cargo": cargo,
        "fk_congregacao": congregacaoSelecionada,
        "fk_familia": familiaSelecionada,
        "fk_turma": turmaSelecionada, // 🔥 AQUI
        "data_nascimento": dataNascimento?.toIso8601String(),
      }),
    );

    if (res.statusCode == 200) {
      Navigator.pop(context);
    }
  }

  Widget campo(String label, TextEditingController controller,
      {TextInputFormatter? mask}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        inputFormatters: mask != null ? [mask] : [],
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Editar Membro")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            campo("Nome", nome),
            campo("Telefone", telefone, mask: telefoneMask),

            SizedBox(height: 10),

            DropdownButtonFormField<int>(
              hint: Text("Turma EBD"),
              value: turmaSelecionada,
              items: turmas.map<DropdownMenuItem<int>>((t) {
                return DropdownMenuItem(
                  value: t["id"],
                  child: Text(t["nome"]),
                );
              }).toList(),
              onChanged: (v) => setState(() => turmaSelecionada = v),
            ),

            SizedBox(height: 20),

            ElevatedButton(onPressed: salvar, child: Text("Salvar"))
          ],
        ),
      ),
    );
  }
}

