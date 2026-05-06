// ==========================================
// MEMBRO CREATE (COM TURMA EBD)
// ==========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'api_service.dart';

class MembroCreatePage extends StatefulWidget {
  @override
  _MembroCreatePageState createState() => _MembroCreatePageState();
}

class _MembroCreatePageState extends State<MembroCreatePage> {

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

  final telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');
  final cepMask = MaskTextInputFormatter(mask: '#####-###');

  List<String> cargos = [
    "Membro","Pastor","Presbítero","Missionário(a)",
    "Evangelista","Diácono","Diaconisa","Professor(a) EBD","Líder"
  ];

  List congregacoes = [];
  List familias = [];
  List turmas = [];

  int? congregacaoSelecionada;
  int? familiaSelecionada;
  int? turmaSelecionada;

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

  @override
  void initState() {
    super.initState();
    carregarRelacoes();
  }

  Future salvar() async {

    if (familiaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecione uma família")),
      );
      return;
    }

    final res = await ApiService.post(
      "/membros",
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

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.pop(context, true);
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
      appBar: AppBar(title: Text("Novo Membro")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            campo("Nome", nome),
            campo("Telefone", telefone, mask: telefoneMask),
            campo("Endereço", endereco),
            campo("Bairro", bairro),
            campo("CEP", cep, mask: cepMask),
            campo("Município", municipio),
            campo("Estado", estado),
            campo("Email", email),

            SizedBox(height: 10),

            InkWell(
              onTap: () async {
                final data = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (data != null) setState(() => dataNascimento = data);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "Data de Nascimento",
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  dataNascimento == null
                      ? "Selecione a data"
                      : "${dataNascimento!.day}/${dataNascimento!.month}/${dataNascimento!.year}",
                ),
              ),
            ),

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

            SizedBox(height: 10),

            DropdownButtonFormField<int>(
              hint: Text("Sem congregação"),
              value: congregacaoSelecionada,
              items: congregacoes.map<DropdownMenuItem<int>>((c) {
                return DropdownMenuItem(
                  value: c["id"],
                  child: Text(c["nome"]),
                );
              }).toList(),
              onChanged: (v) => setState(() => congregacaoSelecionada = v),
            ),

            SizedBox(height: 10),

            DropdownButtonFormField<int>(
              hint: Text("Família"),
              value: familiaSelecionada,
              items: familias.map<DropdownMenuItem<int>>((f) {
                return DropdownMenuItem(
                  value: f["id"],
                  child: Text(f["nome"]),
                );
              }).toList(),
              onChanged: (v) => setState(() => familiaSelecionada = v),
            ),

            SizedBox(height: 10),

            DropdownButtonFormField(
              value: cargo,
              items: cargos.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (v) => setState(() => cargo = v.toString()),
            ),

            SizedBox(height: 20),

            ElevatedButton(onPressed: salvar, child: Text("Salvar")),
          ],
        ),
      ),
    );
  }
}

