import 'package:flutter/material.dart';
import 'models/familia.dart';
import 'data/membros_data.dart';

class FamiliaDetalhePage extends StatelessWidget {

  final Familia familia;

  FamiliaDetalhePage({required this.familia});

  @override
  Widget build(BuildContext context) {

    final membrosDaFamilia =
       listaMembros.where((m) => m.fkFamilia == familia.id).toList();

    return Scaffold(

      appBar: AppBar(
        title: Text(familia.nome),
      ),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: membrosDaFamilia.isEmpty
            ? Center(child: Text("Nenhum membro nesta família"))
            : ListView.builder(

                itemCount: membrosDaFamilia.length,

                itemBuilder: (context, index) {

                  final membro = membrosDaFamilia[index];

                  return ListTile(

                    leading: Icon(Icons.person),

                    title: Text(membro.nome),

                    subtitle: Text(membro.telefone ?? ""),

                  );

                },

              ),

      ),

    );

  }

}
