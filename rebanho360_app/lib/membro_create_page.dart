import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool loading = false;

  final telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');
  final cepMask = MaskTextInputFormatter(mask: '#####-###');

  String formatarData(DateTime data) {
    return "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
  }

  Future salvar() async {
    setState(() => loading = true);

    try {
      final res = await ApiService.post(
        "/membros",
        {
          "nome": nome.text,
          "telefone": telefone.text,
          "endereco": endereco.text,
          "bairro": bairro.text,
          "cep": cep.text,
          "municipio": municipio.text,
          "estado": estado.text,
          "email": email.text,
          "cargo": cargo,
          "fk_congregacao": null,
          "fk_familia": null,
          "data_nascimento": dataNascimento != null
              ? formatarData(dataNascimento!)
              : null,
        },
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Membro cadastrado")),
        );
        Navigator.pop(context);
      } else {
        print(res.body);
      }

    } catch (e) {
      print(e);
    }

    setState(() => loading = false);
  }

  Widget campo(String label, TextEditingController controller,
      {TextInputFormatter? mask}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        inputFormatters: mask != null ? [mask] : [],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
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
                if (data != null) {
                  setState(() => dataNascimento = data);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "Data de Nascimento",
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  dataNascimento == null
                      ? "Selecione a data"
                      : formatarData(dataNascimento!),
                ),
              ),
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : salvar,
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Salvar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

