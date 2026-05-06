// ==========================================
// APP DO MEMBRO (COM EBD + LEITURA + DEVOCIONAL)
// ==========================================

import 'package:flutter/material.dart';

import 'perfil_page.dart';
import 'avisos_page.dart';
import 'oracao_page.dart';
import 'agenda_page.dart';
import 'oferta_page.dart';
import 'pg_page.dart';
import 'carteirinha_page.dart';
import 'agendamento_page.dart';
import 'membro_ebd_page.dart';
import 'chat_page.dart';
import 'membros_page.dart';
import 'login_page.dart';

// 🔥 NOVOS
import 'leitura_page.dart';
import 'devocional_page.dart';
import 'api_service.dart'; // 🔥 IMPORTANTE PARA LOGOUT
import 'chat_list_page.dart';

class AppMembro extends StatefulWidget {
  final int membroId;

  AppMembro({required this.membroId});

  @override
  _AppMembroState createState() => _AppMembroState();
}

class _AppMembroState extends State<AppMembro> {

  int pagina = 0;

  late List<Widget> paginas;

  @override
  void initState() {
    super.initState();

    final id = widget.membroId == 0 ? 1 : widget.membroId;

    paginas = [

      // 0 - PERFIL
      PerfilPage(
        membroId: id,
        mudarPagina: (i) {
          setState(() {
            pagina = i;
          });
        },
      ),

      // 1 - AVISOS
      AvisosPage(),

      // 2 - ORAÇÃO
      OracaoPage(),

      // 3 - AGENDA
      AgendaPage(tipoUsuario: "membro"),

      // 4 - OFERTAS
      OfertaPage(),

      // 5 - PG
      PGPage(tipoUsuario: "membro"),

      // 6 - EBD
      MembroEBDPage(),

      // 7 - LEITURA
      LeituraPage(),

      // 8 - DEVOCIONAL
      DevocionalPage(),

      // 9 - CARTEIRINHA
      CarteirinhaPage(membroId: id),

      // 10 - AGENDAMENTO
      AgendamentoPage(),

      // 11 - CHAT (LISTA DE CONTATOS)
     ChatListPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Área do Membro"),

        // 🔥 BOTÃO SAIR
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => LoginPage()),
    (route) => false,
  );

},
          )
        ],
      ),

      body: paginas[pagina],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pagina,
        onTap: (i) => setState(() => pagina = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [

          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Perfil"),

          BottomNavigationBarItem(
              icon: Icon(Icons.campaign), label: "Avisos"),

          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Oração"),

          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Agenda"),

          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: "Ofertas"),

          BottomNavigationBarItem(
              icon: Icon(Icons.groups), label: "PG"),

          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: "EBD"),

          BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories), label: "Leitura"),

          BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement), label: "Devocional"),

          BottomNavigationBarItem(
              icon: Icon(Icons.badge), label: "Carteira"),

          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Agendamento"),

          BottomNavigationBarItem(
              icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
    );
  }
}
