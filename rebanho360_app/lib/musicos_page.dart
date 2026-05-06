import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

// ==========================================
// PAGE
// ==========================================

class MusicosPage extends StatefulWidget {
  @override
  _MusicosPageState createState() => _MusicosPageState();
}

class _MusicosPageState extends State<MusicosPage> {

  List musicos = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {
    final res = await ApiService.get("/musicos");

    setState(() {
      musicos = jsonDecode(res.body);
    });
  }

  Future excluir(int id) async {
    await ApiService.delete("/musicos/$id");
    carregar();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Músicos")),

      body: musicos.isEmpty
          ? Center(child: Text("Nenhum músico cadastrado"))
          : ListView.builder(
              itemCount: musicos.length,
              itemBuilder: (context, index) {

                final m = musicos[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.music_note, color: Colors.white),
                    ),
                    title: Text(m["nome"] ?? ""),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Instrumento: ${m["instrumento"] ?? ""}"),
                        Text("Nível: ${m["nivel"] ?? ""}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => excluir(m["id"]),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => DialogCadastroMusico(onSalvo: carregar),
          );
        },
      ),
    );
  }
}

// ==========================================
// DIALOGO CADASTRO
// ==========================================

class DialogCadastroMusico extends StatefulWidget {
  final Function onSalvo;

  DialogCadastroMusico({required this.onSalvo});

  @override
  _DialogCadastroMusicoState createState() => _DialogCadastroMusicoState();
}

class _DialogCadastroMusicoState extends State<DialogCadastroMusico> {

  List membros = [];
  int? membroSelecionado;

  String instrumento = "Violão";
  String nivel = "Intermediário";

  @override
  void initState() {
    super.initState();
    carregarMembros();
  }

  Future carregarMembros() async {
    final res = await ApiService.get("/membros");

    setState(() {
      membros = jsonDecode(res.body);
    });
  }

  Future salvar() async {

    if (membroSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecione um membro")),
      );
      return;
    }

    final response = await ApiService.post(
      "/musicos",
      jsonEncode({
        "membro_id": membroSelecionado,
        "instrumento": instrumento,
        "nivel": nivel
      }),
    );

    print("STATUS MUSICO: ${response.statusCode}");
    print("BODY MUSICO: ${response.body}");

    widget.onSalvo();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text("Novo Músico"),

      content: SingleChildScrollView(
        child: Column(
          children: [

            DropdownButtonFormField(
              hint: Text("Selecione o membro"),
              items: membros.map<DropdownMenuItem>((m) {
                return DropdownMenuItem(
                  value: m["id"],
                  child: Text(m["nome"]),
                );
              }).toList(),
              onChanged: (v) => setState(() => membroSelecionado = v as int),
            ),

            SizedBox(height: 10),

            DropdownButtonFormField(
              value: instrumento,
              items: [
                "Violão",
                "Guitarra",
                "Baixo",
                "Bateria",
                "Teclado",
                "Vocal"
              ].map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              )).toList(),
              onChanged: (v) => setState(() => instrumento = v.toString()),
            ),

            SizedBox(height: 10),

            DropdownButtonFormField(
              value: nivel,
              items: [
                "Iniciante",
                "Intermediário",
                "Avançado"
              ].map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              )).toList(),
              onChanged: (v) => setState(() => nivel = v.toString()),
            ),

          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: salvar,
          child: Text("Salvar"),
        ),
      ],
    );
  }
}

