// ==========================================
// 1 IMPORTAÇÕES
// ==========================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'financeiro_relatorio_page.dart';
import 'financeiro_fluxo_page.dart';
import 'financeiro_grafico_page.dart';
import 'financeiro_dashboard_page.dart';


// ==========================================
// 2 WIDGET PRINCIPAL
// ==========================================

class FinanceiroPage extends StatefulWidget {
  @override
  _FinanceiroPageState createState() => _FinanceiroPageState();
}


// ==========================================
// 3 STATE
// ==========================================

class _FinanceiroPageState extends State<FinanceiroPage> {

  List dados = [];
  Map resumo = {};

  List membros = [];
  int? membroSelecionado;


// ==========================================
// 4 INIT
// ==========================================

  @override
  void initState() {
    super.initState();
    carregarDados();
    carregarMembros();
  }


// ==========================================
// 5 CARREGAR DADOS
// ==========================================

  Future carregarDados() async {

    final res1 = await http.get(
      Uri.parse("http://localhost:8000/financeiro")
    );

    final res2 = await http.get(
      Uri.parse("http://localhost:8000/financeiro/resumo")
    );

    if (res1.statusCode == 200 && res2.statusCode == 200) {
      setState(() {
        dados = jsonDecode(res1.body);
        resumo = jsonDecode(res2.body);
      });
    }
  }


// ==========================================
// 6 CARREGAR MEMBROS
// ==========================================

  Future carregarMembros() async {

    final response = await http.get(
      Uri.parse("http://localhost:8000/membros")
    );

    if (response.statusCode == 200) {
      setState(() {
        membros = jsonDecode(response.body);
      });
    }
  }


// ==========================================
// 7 FORMULÁRIO FINANCEIRO (COM DATA)
// ==========================================

  void abrirCadastro() {

    String tipo = "entrada";
    String categoria = "";
    DateTime dataSelecionada = DateTime.now();

    TextEditingController valor = TextEditingController();
    TextEditingController descricao = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setStateDialog) {

            return AlertDialog(
              title: Text("Novo Lançamento"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ================= TIPO =================
                    DropdownButtonFormField<String>(
                      value: tipo,
                      items: ["entrada", "saida"].map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setStateDialog(() => tipo = v!);
                      },
                    ),

                    // ================= MEMBRO =================
                    DropdownButtonFormField<int>(
                      hint: Text("Selecionar membro (opcional)"),
                      value: membroSelecionado,
                      items: membros.map<DropdownMenuItem<int>>((m) {
                        return DropdownMenuItem(
                          value: m["id"],
                          child: Text(m["nome"]),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setStateDialog(() {
                          membroSelecionado = v;
                        });
                      },
                    ),

                    // ================= DATA =================
                    ListTile(
                      title: Text("Data"),
                      subtitle: Text(
                        "${dataSelecionada.day}/${dataSelecionada.month}/${dataSelecionada.year}",
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: dataSelecionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (data != null) {
                          setStateDialog(() {
                            dataSelecionada = data;
                          });
                        }
                      },
                    ),

                    // ================= CATEGORIA =================
                    DropdownButtonFormField<String>(
                      hint: Text("Categoria"),
                      items: [
                        "dizimo",
                        "oferta",
                        "oferta_especial",
                        "aluguel",
                        "manutencao",
                        "salario",
                      ].map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (v) => categoria = v!,
                    ),

                    // ================= VALOR =================
                    TextField(
                      controller: valor,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Valor"),
                    ),

                    // ================= DESCRIÇÃO =================
                    TextField(
                      controller: descricao,
                      decoration: InputDecoration(labelText: "Descrição"),
                    ),

                  ],
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),

                ElevatedButton(
                  child: Text("Salvar"),
                  onPressed: () async {

                    try {

                      final response = await http.post(
  Uri.parse("http://localhost:8000/financeiro"),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "membro_id": membroSelecionado,
    "tipo": tipo,
    "categoria": categoria,
    "valor": double.tryParse(valor.text) ?? 0,
    "origem": membroSelecionado != null
        ? "membro"
        : "visitante",
    "descricao": descricao.text,
    "data": dataSelecionada.toIso8601String()
  }),
);
  
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Salvo com sucesso")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erro ao salvar")),
                        );
                      }

                      Navigator.pop(context);
                      carregarDados();

                    } catch (e) {
                      print("ERRO: $e");
                    }

                  },
                ),

              ],
            );
          },
        );
      },
    );
  }


// ==========================================
// 8 UI PRINCIPAL
// ==========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Financeiro"),
        actions: [

          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinanceiroRelatorioPage(),
                ),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinanceiroFluxoPage(),
                ),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.insert_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinanceiroGraficoPage(),
                ),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinanceiroDashboardPage(),
                ),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.add),
            onPressed: abrirCadastro,
          ),

        ],
      ),

      body: Column(
        children: [

          // ================= RESUMO =================
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text("Entradas: R\$ ${resumo["entradas"] ?? 0}"),
                Text("Saídas: R\$ ${resumo["saidas"] ?? 0}"),
                Text("Saldo: R\$ ${resumo["saldo"] ?? 0}"),
              ],
            ),
          ),

          Divider(),

          // ================= LISTA =================
          Expanded(
           child: ListView.builder(
  itemCount: dados.length,
  itemBuilder: (context, index) {

    final item = dados[index];

    return ListTile(
      leading: Icon(
        item["tipo"] == "entrada"
            ? Icons.arrow_downward
            : Icons.arrow_upward,
        color: item["tipo"] == "entrada"
            ? Colors.green
            : Colors.red,
      ),
      title: Text(item["categoria"]),
      subtitle: Text(item["descricao"] ?? ""),
      trailing: Text("R\$ ${item["valor"]}"),
    );
  },
),
          ),

        ],
      ),
    );
  }
}
