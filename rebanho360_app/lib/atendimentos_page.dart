import 'package:flutter/material.dart';
import 'data/atendimentos_data.dart';
import 'models/atendimento.dart';

class AtendimentosPage extends StatefulWidget {

  final String membro;

  AtendimentosPage({required this.membro});

  @override
  _AtendimentosPageState createState() => _AtendimentosPageState();
}

class _AtendimentosPageState extends State<AtendimentosPage> {

  final tipoController = TextEditingController();
  final situacaoController = TextEditingController();
  final observacaoController = TextEditingController();

  void salvar() {

    listaAtendimentos.add(

      Atendimento(
        membro: widget.membro,
        data: DateTime.now().toString().substring(0,10),
        tipo: tipoController.text,
        situacaoEmocional: situacaoController.text,
        observacoes: observacaoController.text,
      ),

    );

    setState(() {

      tipoController.clear();
      situacaoController.clear();
      observacaoController.clear();

    });

  }

  @override
  Widget build(BuildContext context) {

    final atendimentosMembro = listaAtendimentos
        .where((a) => a.membro == widget.membro)
        .toList();

    return Scaffold(

      appBar: AppBar(
        title: Text("Atendimento - ${widget.membro}"),
      ),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: tipoController,
              decoration: InputDecoration(labelText: "Tipo de atendimento"),
            ),

            TextField(
              controller: situacaoController,
              decoration: InputDecoration(labelText: "Situação emocional"),
            ),

            TextField(
              controller: observacaoController,
              decoration: InputDecoration(labelText: "Observações"),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: salvar,
              child: Text("Registrar Atendimento"),
            ),

            SizedBox(height: 20),

            Expanded(

              child: ListView.builder(

                itemCount: atendimentosMembro.length,

                itemBuilder: (context, index) {

                  final atendimento = atendimentosMembro[index];

                  return Card(

                    child: ListTile(

                      title: Text(atendimento.tipo),

                      subtitle: Text(
                        "${atendimento.data}\n${atendimento.observacoes}"
                      ),

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

  }

}
