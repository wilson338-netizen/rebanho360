import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

import 'membros_page.dart';
import 'igrejas_page.dart';
import 'congregacoes_page.dart';
import 'ranking_page.dart';
import 'financeiro_page.dart';
import 'pix_config_page.dart';
import 'agenda_page.dart';
import 'dashboard_page.dart';
import 'musicos_page.dart';
import 'familias_page.dart';
import 'pg_page.dart';
import 'login_page.dart';
import 'ebd_page.dart';
import 'voluntarios_page.dart';
import 'carteirinhas_page.dart';
import 'painel_pastor_page.dart';
import 'devocional_admin_page.dart';
import 'notificacoes_page.dart';

class HomePage extends StatefulWidget {
  final String tipoUsuario;

  HomePage({required this.tipoUsuario});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int paginaAtual = 0;
  int notificacoes = 0; // 🔥 NOVO

  Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  // 🔥 CARREGAR CONTADOR
  Future carregarNotificacoes() async {
    final res = await ApiService.get("/membro/notificacoes/contador");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        notificacoes = data["total"] ?? 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarNotificacoes(); // 🔥
  }

  @override
  Widget build(BuildContext context) {

    final telaGrande = MediaQuery.of(context).size.width > 800;

    final paginas = [
      DashboardPage(),
      MembrosPage(),
      MusicosPage(),
      FamiliasPage(),
      PGPage(tipoUsuario: widget.tipoUsuario),
      AgendaPage(tipoUsuario: widget.tipoUsuario),
      EBDPage(),
      VoluntariosPage(),
      CarteirinhasPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Rebanho360"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [

            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
              onTap: () => setState(() => paginaAtual = 0),
            ),

            ListTile(
              leading: Icon(Icons.people),
              title: Text("Membros"),
              onTap: () => setState(() => paginaAtual = 1),
            ),

            ListTile(
              leading: Icon(Icons.music_note),
              title: Text("Músicos"),
              onTap: () => setState(() => paginaAtual = 2),
            ),

            ListTile(
              leading: Icon(Icons.family_restroom),
              title: Text("Famílias"),
              onTap: () => setState(() => paginaAtual = 3),
            ),

            ListTile(
              leading: Icon(Icons.groups),
              title: Text("PG"),
              onTap: () => setState(() => paginaAtual = 4),
            ),

            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text("Agenda"),
              onTap: () => setState(() => paginaAtual = 5),
            ),

            ListTile(
              leading: Icon(Icons.menu_book),
              title: Text("EBD"),
              onTap: () => setState(() => paginaAtual = 6),
            ),

            ListTile(
              leading: Icon(Icons.volunteer_activism),
              title: Text("Voluntários"),
              onTap: () => setState(() => paginaAtual = 7),
            ),

            ListTile(
              leading: Icon(Icons.badge),
              title: Text("Carteirinhas"),
              onTap: () => setState(() => paginaAtual = 8),
            ),

            Divider(),

            // 🔥 ADMIN / PASTOR
            if (widget.tipoUsuario != "membro") ...[

              ListTile(
                leading: Icon(Icons.dashboard_customize),
                title: Text("Painel do Pastor"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PainelPastorPage()),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.menu_book),
                title: Text("Devocional (Admin)"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DevocionalAdminPage()),
                  );
                },
              ),

              // 🔥 NOTIFICAÇÕES COM BADGE
              ListTile(
                leading: Stack(
                  children: [
                    Icon(Icons.notifications),
                    if (notificacoes > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            notificacoes.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text("Notificações"),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificacoesPage()),
                  );

                  carregarNotificacoes(); // 🔥 ATUALIZA AO VOLTAR
                },
              ),

            ],

          ],
        ),
      ),

      body: telaGrande
          ? Row(
              children: [

                NavigationRail(
                  selectedIndex: paginaAtual,
                  onDestinationSelected: (index) {
                    setState(() => paginaAtual = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  scrollable: true,
                  destinations: const [

                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard),
                      label: Text("Dashboard"),
                    ),

                    NavigationRailDestination(
                      icon: Icon(Icons.people),
                      label: Text("Membros"),
                    ),

                    NavigationRailDestination(
                      icon: Icon(Icons.music_note),
                      label: Text("Músicos"),
                    ),

                    NavigationRailDestination(
                      icon: Icon(Icons.family_restroom),
                      label: Text("Famílias"),
                    ),

                    NavigationRailDestination(
                      icon: Icon(Icons.groups),
                      label: Text("PG"),
                    ),

                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month),
                      label: Text("Agenda"),
                    ),

                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book),
                      label: Text("EBD"),
                    ),

                    NavigationRailDestination(
                      icon: Icon(Icons.volunteer_activism),
                      label: Text("Voluntários"),
                    ),

                    NavigationRailDestination(
                      icon: Icon(Icons.badge),
                      label: Text("Carteirinhas"),
                    ),
                  ],
                ),

                Expanded(
                  child: paginas[paginaAtual],
                ),

              ],
            )
          : paginas[paginaAtual],

      bottomNavigationBar: telaGrande
          ? null
          : BottomNavigationBar(
              currentIndex: paginaAtual,
              onTap: (index) {
                setState(() => paginaAtual = index);
              },
              type: BottomNavigationBarType.fixed,
              items: const [

                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: "Dashboard",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: "Membros",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.music_note),
                  label: "Músicos",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.family_restroom),
                  label: "Famílias",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.groups),
                  label: "PG",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: "Agenda",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book),
                  label: "EBD",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.volunteer_activism),
                  label: "Voluntários",
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.badge),
                  label: "Carteirinhas",
                ),
              ],
            ),
    );
  }
}

