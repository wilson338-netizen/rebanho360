// ============================================
// IMPORTAÇÕES
// ============================================

import 'package:flutter/material.dart';


// ============================================
// TELA DETALHE DO MEMBRO
// ============================================

class MembroDetalhePage extends StatelessWidget {

  final Map membro;

  MembroDetalhePage({required this.membro});


// ============================================
// INTERFACE
// ============================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Detalhes do Membro"),
      ),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              membro["nome"] ?? "",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text("Telefone: ${membro["telefone"] ?? ""}"),

            SizedBox(height: 10),

            Text("Endereço: ${membro["endereco"] ?? ""}"),

          ],

        ),
      ),
    );
  }
}
