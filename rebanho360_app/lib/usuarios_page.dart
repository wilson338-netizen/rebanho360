import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsuariosPage extends StatefulWidget {
  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {

  List membros = [];

  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();

  int? membroSelecionado;
  String nomeSelecionado = "";

  String tipoSelecionado = "membro";
  bool carregando = false;

  // ==========================
  // CARREGAR MEMBROS
  // ==========================
  Future carregarMembros() async {

    final res = await http.get(
      Uri.parse("http://127.0.0.1:8000/membros")
    );

    setState(() {
      membros = jsonDecode(res.body);
    });
  }

  // ==========================
  // CRIAR USUARIO
  // ==========================
  Future criarUsuario() async {

    if (membroSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecione um membro primeiro")),
      );
      return;
    }

    if (email.text.isEmpty || senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha email e senha")),
      );
      return;
    }

    setState(() => carregando = true);

    final res = await http.post(
      Uri.parse("http://127.0.0.1:8000/usuarios"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": nomeSelecionado, // 👈 vem do membro
        "email": email.text,
        "senha": senha.text,
        "tipo": tipoSelecionado,
        "membro_id": membroSelecionado
      }),
    );

    setState(() => carregando = false);

    if (res.statusCode == 200) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuário criado com sucesso")),
      );

      email.clear();
      senha.clear();

      setState(() {
        membroSelecionado = null;
        nomeSelecionado = "";
        tipoSelecionado = "membro";
      });

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: ${res.body}")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    carregarMembros();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Criar Usuário")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ==========================
            // MEMBRO
            // ==========================
            DropdownButtonFormField(
              hint: Text("Selecionar membro"),
              value: membroSelecionado,
              items: membros.map<DropdownMenuItem>((m) {
                return DropdownMenuItem(
                  value: m["id"],
                  child: Text(m["nome"]),
                );
              }).toList(),
              onChanged: (v) {
                final membro = membros.firstWhere((m) => m["id"] == v);

                setState(() {
                  membroSelecionado = v;
                  nomeSelecionado = membro["nome"];
                });
              },
            ),

            SizedBox(height: 10),

            // MOSTRA NOME SELECIONADO
            if (nomeSelecionado.isNotEmpty)
              Text(
                "Membro: $nomeSelecionado",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

            SizedBox(height: 15),

            // ==========================
            // TIPO
            // ==========================
            DropdownButtonFormField(
              value: tipoSelecionado,
              decoration: InputDecoration(labelText: "Tipo de usuário"),
              items: [
                DropdownMenuItem(value: "membro", child: Text("Membro")),
                DropdownMenuItem(value: "pastor", child: Text("Pastor")),
                DropdownMenuItem(value: "admin", child: Text("Administrador")),
              ],
              onChanged: (v) => setState(() => tipoSelecionado = v.toString()),
            ),

            SizedBox(height: 15),

            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: senha,
              obscureText: true,
              decoration: InputDecoration(labelText: "Senha"),
            ),

            SizedBox(height: 20),

            carregando
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: criarUsuario,
                    child: Text("Criar Login"),
                  ),

          ],
        ),
      ),
    );
  }
}
