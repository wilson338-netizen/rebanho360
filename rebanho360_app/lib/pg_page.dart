import 'package:flutter/material.dart';
import 'dart:convert';

import 'api_service.dart';
import 'models/pg_model.dart';
import 'utils/gerador_pg.dart';
import 'pg_detalhe_page.dart';

// ==========================================
// PAGE
// ==========================================

class PGPage extends StatefulWidget {
  final String tipoUsuario;

  PGPage({required this.tipoUsuario});

  @override
  _PGPageState createState() => _PGPageState();
}

// ==========================================
// STATE
// ==========================================

class _PGPageState extends State<PGPage> {

  List<PG> listaPG = [];

  @override
  void initState() {
    super.initState();
    carregarPG();
  }

  // ==========================================
  // BUSCAR PG
  // ==========================================

  Future carregarPG() async {

  try {
    final response = await ApiService.get("/celulas");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      setState(() {
        listaPG = data.map<PG>((item) => PG(
          id: item["id"] ?? 0,
          nome: (item["nome"] ?? "").toString(),
          lider: (item["lider"] ?? "").toString(),
          dia: (item["dia_semana"] ?? "").toString(),
          endereco: (item["bairro"] ?? "").toString(),
        )).toList();
      });

    } else {
      print("Erro ao carregar PG: ${response.statusCode}");
    }
  } catch (e) {
    print("Erro PG: $e");
  }
}


  // ==========================================
  // CRIAR PG (ADMIN)
  // ==========================================

  Future criarPG(String nome, String lider, String dia, String endereco) async {

    final response = await ApiService.post(
      "/celulas",
      jsonEncode({
        "nome": nome,
        "lider": lider,
        "dia_semana": dia,
        "bairro": endereco
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      carregarPG();
    } else {
      print("Erro ao criar PG: ${response.body}");
    }
  }

  // ==========================================
  // ENTRAR NO PG (MEMBRO)
  // ==========================================

  Future entrarNoPG(int pgId) async {

    try {
      final response = await ApiService.post(
        "/pg/entrar",
        jsonEncode({"pg_id": pgId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Você entrou no PG!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao entrar no PG")),
        );
      }

    } catch (e) {
      print("Erro entrar PG: $e");
    }
  }

  // ==========================================
  // DIALOG CRIAR PG
  // ==========================================

  void mostrarDialogCriarPG() {

    TextEditingController nomeController = TextEditingController();
    TextEditingController liderController = TextEditingController();
    TextEditingController diaController = TextEditingController();
    TextEditingController enderecoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: Text("Novo PG"),

          content: SingleChildScrollView(
            child: Column(
              children: [

                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(labelText: "Nome do PG"),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: liderController,
                  decoration: InputDecoration(labelText: "Líder"),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: diaController,
                  decoration: InputDecoration(labelText: "Dia da semana"),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: enderecoController,
                  decoration: InputDecoration(labelText: "Endereço"),
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
              onPressed: () {

                criarPG(
                  nomeController.text,
                  liderController.text,
                  diaController.text,
                  enderecoController.text,
                );

                Navigator.pop(context);
              },
              child: Text("Salvar"),
            ),

          ],
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
        title: Text("Pequenos Grupos"),

        actions: [

          IconButton(
            icon: Icon(Icons.lightbulb),
            onPressed: gerarPensamento,
          ),

          // 🔥 SOMENTE ADMIN
          if (widget.tipoUsuario == "admin" || widget.tipoUsuario == "pastor")
            IconButton(
              icon: Icon(Icons.add),
              onPressed: mostrarDialogCriarPG,
            ),

        ],
      ),

      body: ListView.builder(
        itemCount: listaPG.length,
        itemBuilder: (context, index) {

          final pg = listaPG[index];

          return Card(
            child: ListTile(
              leading: Icon(Icons.groups),
              title: Text(pg.nome ?? ""),
subtitle: Text("Líder: ${pg.lider ?? ""} | Dia: ${pg.dia ?? ""}"),

              // 🔥 AQUI ESTÁ A MÁGICA
              trailing: widget.tipoUsuario == "membro"
                  ? ElevatedButton(
                      onPressed: () => entrarNoPG(pg.id),
                      child: Text("Participar"),
                    )
                  : null,

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PGDetalhePage(pg: pg),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // GERADOR
  // ==========================================

  void gerarPensamento() {

    final conteudo = GeradorPG.gerar();

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: Text("Pensamento para PG"),
          content: Text(conteudo["pensamento"]!),
          actions: [
            TextButton(
              child: Text("Fechar"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }
}

