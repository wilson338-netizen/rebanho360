// ==========================================
// IMPORTS
// ==========================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// ==========================================
// PAGE
// ==========================================

class MinistrosPage extends StatefulWidget {
  @override
  _MinistrosPageState createState() => _MinistrosPageState();
}


// ==========================================
// STATE
// ==========================================

class _MinistrosPageState extends State<MinistrosPage> {

  List ministros = [];

  // ==========================================
  // INIT
  // ==========================================

  @override
  void initState() {
    super.initState();
    carregarMinistros();
  }

  // ==========================================
  // CARREGAR MINISTROS
  // ==========================================

  Future carregarMinistros() async {

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/ministros")
    );

    if (response.statusCode == 200) {
      setState(() {
        ministros = jsonDecode(response.body);
      });
    }
  }

  // ==========================================
  // SALVAR MINISTRO
  // ==========================================

  Future salvarMinistro(int membroId, String cargo) async {

  final url = Uri.parse("${ApiService.baseUrl}/ministros");

  await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "membro_id": membroId,
      "cargo": cargo,
      "data_consagracao": "2026-01-01"
    }),
  );

  carregarMinistros();
}

  // ==========================================
  // DIALOG CADASTRO
  // ==========================================

 void abrirDialogCadastro() async {

  List membros = [];
  int? membroSelecionado;
  String? cargoSelecionado;

  // 🔥 buscar membros
  final response = await http.get(
    Uri.parse("${ApiService.baseUrl}/membros")
  );

  if (response.statusCode == 200) {
    membros = jsonDecode(response.body);
  }

  showDialog(
    context: context,
    builder: (context) {

      return StatefulBuilder(
        builder: (context, setStateDialog) {

          return AlertDialog(
            title: Text("Cadastrar Ministro"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // 👤 MEMBRO
                DropdownButtonFormField<int>(
                  hint: Text("Selecionar membro"),
                  value: membroSelecionado,
                  items: membros.map<DropdownMenuItem<int>>((m) {
                    return DropdownMenuItem<int>(
                      value: m["id"],
                      child: Text(m["nome"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      membroSelecionado = value;
                    });
                  },
                ),

                SizedBox(height: 15),

                // 🎖 CARGO
                DropdownButtonFormField<String>(
                  hint: Text("Selecionar cargo"),
                  value: cargoSelecionado,
                  items: [
                    "Pastor",
                    "Presbítero",
                    "Diácono",
                    "Missionário",
                    "Evangelista",
                    "Líder"
                  ].map((cargo) {
                    return DropdownMenuItem(
                      value: cargo,
                      child: Text(cargo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      cargoSelecionado = value;
                    });
                  },
                ),

              ],
            ),

            actions: [

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),

              ElevatedButton(
                onPressed: () async {

                  if (membroSelecionado != null &&
                      cargoSelecionado != null) {

                    await salvarMinistro(
                      membroSelecionado!,
                      cargoSelecionado!,
                    );

                    Navigator.pop(context);
                  }
                },
                child: Text("Salvar"),
              ),

            ],
          );
        },
      );
    },
  );
}

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Ministros"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: abrirDialogCadastro,
          )
        ],
      ),

      body: ListView.builder(
        itemCount: ministros.length,
        itemBuilder: (context, index) {

          final item = ministros[index];

          return Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(item["nome"]),
              subtitle: Text(item["cargo"]),
            ),
          );
        },
      ),
    );
  }
}