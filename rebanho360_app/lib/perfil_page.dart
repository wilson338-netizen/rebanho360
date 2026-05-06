// ==========================================
// PERFIL DO MEMBRO (COM MENU INTEGRADO)
// ==========================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'api_service.dart';
import 'login_page.dart';

class PerfilPage extends StatefulWidget {
  final int membroId;
  final Function(int) mudarPagina;

  PerfilPage({
    required this.membroId,
    required this.mudarPagina,
  });

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {

  TextEditingController nome = TextEditingController();
  TextEditingController telefone = TextEditingController();
  TextEditingController endereco = TextEditingController();
  TextEditingController documento = TextEditingController();

  String foto = "";
  bool editando = false;

  // ================= CARREGAR =================
Future carregar() async {

  final res = await ApiService.get("/membros/${widget.membroId}");

  if (res.statusCode != 200) return;

  final data = jsonDecode(res.body);

  setState(() {
    nome.text = data["nome"] ?? "";
    telefone.text = data["telefone"] ?? "";
    endereco.text = data["endereco"] ?? "";
    documento.text = data["documento"] ?? "";
    foto = data["foto"] ?? "";
  });
}

  // ================= SALVAR =================
  Future salvar() async {

    await http.put(
      Uri.parse(
        "http://localhost:8000/membros/${widget.membroId}"
        "?telefone=${telefone.text}&endereco=${endereco.text}&documento=${documento.text}"
      ),
    );

    setState(() {
      editando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Dados atualizados 🔥")),
    );
  }

  // ================= FOTO =================
  void uploadFoto() {

    final uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((event) {

      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((event) async {

        var request = http.MultipartRequest(
          "POST",
          Uri.parse("http://localhost:8000/membros/${widget.membroId}/foto"),
        );

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            reader.result as List<int>,
            filename: file.name,
          ),
        );

        await request.send();
        carregar();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  // ================= CAMPO =================
  Widget campo(IconData icon, String label, TextEditingController controller, {bool bloqueado = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        enabled: !bloqueado && editando,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ================= MENU =================
  Widget menuItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {

        if (index == -1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
          );
        } else {
          widget.mudarPagina(index);
        }

      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(height: 5),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 40, bottom: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white24,
                    backgroundImage: foto.isNotEmpty
                        ? NetworkImage("http://localhost:8000/$foto")
                        : null,
                    child: foto.isEmpty
                        ? Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),

                  SizedBox(height: 10),

                  Text(
                    nome.text,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),

                  SizedBox(height: 5),

                  ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text(editando ? "Cancelar" : "Editar"),
                    onPressed: () {
                      setState(() {
                        editando = !editando;
                      });
                    },
                  ),

                  SizedBox(height: 10),

                  GestureDetector(
                    onTap: uploadFoto,
                    child: Text(
                      "Alterar Foto",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ================= CAMPOS =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [

                  campo(Icons.person, "Nome", nome, bloqueado: true),
                  campo(Icons.badge, "Documento", documento),
                  campo(Icons.phone, "Telefone", telefone),
                  campo(Icons.location_on, "Endereço", endereco),

                  SizedBox(height: 10),

                  if (editando)
                    ElevatedButton(
                      onPressed: salvar,
                      child: Text("Salvar"),
                    ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ================= MENU =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [

                  menuItem(Icons.badge, "Carteira", 6),
                  menuItem(Icons.event, "Agenda", 3),
                  menuItem(Icons.campaign, "Avisos", 1),
                  menuItem(Icons.favorite, "Oração", 2),
                  menuItem(Icons.attach_money, "Ofertas", 4),
                  menuItem(Icons.logout, "Sair", -1),

                ],
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

