import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';

class EBDPresencaPage extends StatefulWidget {
  final Map turma;

  EBDPresencaPage({required this.turma});

  @override
  _EBDPresencaPageState createState() => _EBDPresencaPageState();
}

class _EBDPresencaPageState extends State<EBDPresencaPage> {

  List membros = [];
  Map<int, bool> presenca = {};

  Future carregar() async {

    final res = await ApiService.get("/ebd/membros?turma=${widget.turma["id"]}");

    if (res.statusCode == 200) {
      membros = jsonDecode(res.body);

      for (var m in membros) {
        presenca[m["id"]] = true;
      }

      setState(() {});
    }
  }

  Future salvar() async {

    List lista = [];

    presenca.forEach((id, presente) {
      lista.add({
        "membro_id": id,
        "turma_id": widget.turma["id"],
        "presente": presente
      });
    });

    await ApiService.post(
      "/ebd/presenca",
      jsonEncode({"presenca": lista}),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Presença salva")),
    );
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Presença - ${widget.turma["nome"]}"),
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: membros.length,
              itemBuilder: (_, i) {

                final m = membros[i];

                return CheckboxListTile(
                  title: Text(m["nome"]),
                  value: presenca[m["id"]] ?? false,
                  onChanged: (v) {
                    setState(() {
                      presenca[m["id"]] = v!;
                    });
                  },
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: salvar,
            child: Text("Salvar Presença"),
          ),

        ],
      ),
    );
  }
}

