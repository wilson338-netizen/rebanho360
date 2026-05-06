import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'segmentos_page.dart';
import 'package:rebanho360_app/dashboard_ebd_page.dart';


class EBDPage extends StatefulWidget {
  @override
  _EBDPageState createState() => _EBDPageState();
}

class _EBDPageState extends State<EBDPage> with TickerProviderStateMixin {

  late TabController _tabController;

  List membros = [];
  Map<int, bool> presenca = {};
  List ranking = [];

  String turma = "Adulto";

  final List<String> segmentos = [
    "Adulto",
    "Jovens",
    "Adolescente",
    "Infantil",
    "Berçário"
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    carregar();
    carregarUltimaPresenca();
    carregarRanking();
  }

  String get baseUrl {
    return "http://localhost:8000";
  }

  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  Future carregar() async {
    final headers = await getHeaders();

    final res = await http.get(
      Uri.parse("$baseUrl/membros"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      setState(() {
        membros = jsonDecode(res.body);
      });
    }
  }

  List membrosFiltrados() {
    return membros.where((m) {
      return (m["segmento"] ?? "") == turma;
    }).toList();
  }

  int get total => membrosFiltrados().length;

  int get presentes =>
      presenca.values.where((p) => p == true).length;

  Future carregarUltimaPresenca() async {
    final headers = await getHeaders();

    final res = await http.get(
      Uri.parse("$baseUrl/ebd/ultima?turma=$turma"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final lista = jsonDecode(res.body);

      setState(() {
        presenca.clear();
        for (var item in lista) {
          presenca[item["membro_id"]] = item["presente"];
        }
      });
    }
  }

  Future carregarRanking() async {
    final headers = await getHeaders();

    final res = await http.get(
      Uri.parse("$baseUrl/ebd/ranking"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      setState(() {
        ranking = jsonDecode(res.body);
      });
    }
  }

  Future salvar() async {
    final headers = await getHeaders();

    List dados = membrosFiltrados().map((m) {
      return {
        "membro_id": m["id"],
        "presente": presenca[m["id"]] ?? false
      };
    }).toList();

    await http.post(
      Uri.parse("$baseUrl/ebd/presenca"),
      headers: headers,
      body: jsonEncode({
        "turma": turma,
        "presenca": dados
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Presença salva com sucesso 🔥"))
    );
  }

  // ================= CHAMADA =================
  Widget _buildChamada() {
    return Column(
      children: [

        Padding(
          padding: EdgeInsets.all(10),
          child: DropdownButtonFormField<String>(
            value: segmentos.contains(turma) ? turma : null,
            decoration: InputDecoration(
              labelText: "Segmento",
              border: OutlineInputBorder(),
            ),
            items: segmentos.map((s) {
              return DropdownMenuItem<String>(
                value: s,
                child: Text(s),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                turma = v!;
              });
              carregarUltimaPresenca();
            },
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total: $total"),
              Text("Presentes: $presentes"),
            ],
          ),
        ),

        Expanded(
          child: membrosFiltrados().isEmpty
              ? Center(child: Text("Sem membros"))
              : ListView.builder(
                  itemCount: membrosFiltrados().length,
                  itemBuilder: (context, i) {
                    final m = membrosFiltrados()[i];
                    final marcado = presenca[m["id"]] ?? false;

                    return Card(
                      color: marcado
                          ? Colors.green.withOpacity(0.2)
                          : null,
                      child: ListTile(
                        title: Text(m["nome"] ?? ""),
                        trailing: Checkbox(
                          value: marcado,
                          onChanged: (v) {
                            setState(() {
                              presenca[m["id"]] = v!;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),

        ElevatedButton(
          onPressed: salvar,
          child: Text("Salvar Presença"),
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("EBD"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Chamada"),
            Tab(text: "Dashboard"),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SegmentosPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChamada(),
          DashboardEBDPage(), // ✅ agora funciona
        ],
      ),
    );
  }
}

