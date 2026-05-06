import 'package:flutter/material.dart';
import 'data/familias_data.dart';
import 'models/familia.dart';
import 'api_service.dart';

class CadastroFamiliaPage extends StatelessWidget {

  final nomeController = TextEditingController();
  final enderecoController = TextEditingController();
  final telefoneController = TextEditingController();
  final observacoesController = TextEditingController();

 void salvarFamilia(BuildContext context) async {

  final response = await ApiService.post(
    "/familias",
    {
      "nome": nomeController.text,
      "telefone": telefoneController.text,
      "endereco": enderecoController.text,
      "observacoes": observacoesController.text,
    },
  );

  if (response.statusCode == 200) {
   Navigator.pop(context, true);
  } else {
    print("Erro ao salvar família");
  }
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Nova Família"),
      ),

      body: Padding(

        padding: EdgeInsets.all(20),

        child: ListView(

          children: [

            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: "Nome da Família",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            TextField(
              controller: enderecoController,
              decoration: InputDecoration(
                labelText: "Endereço",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            TextField(
              controller: telefoneController,
              decoration: InputDecoration(
                labelText: "Telefone",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            TextField(
              controller: observacoesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Observações",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  salvarFamilia(context);
                },
                child: Text("Salvar Família"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
