import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  Map dados = {};
  List ultimos = [];
  List mensal = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDashboard();
  }

  Future carregarDashboard() async {
    try {

      final res1 = await ApiService.get("/dashboard");
      final res2 = await ApiService.get("/dashboard/detalhado");

      if (res1.statusCode == 200 && res2.statusCode == 200) {

        setState(() {
          dados = jsonDecode(res1.body);

          final det = jsonDecode(res2.body);
          ultimos = det["ultimos"];
          mensal = det["mensal"];

          carregando = false;
        });

      }

    } catch (e) {
      print("ERRO DASHBOARD: $e");
      setState(() => carregando = false);
    }
  }

  Widget card(String titulo, String valor, IconData icon, Color cor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: cor),
              SizedBox(height: 10),
              Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(titulo),
            ],
          ),
        ),
      ),
    );
  }

  Widget grafico() {

    if (mensal.isEmpty) {
      return Text("Sem dados para gráfico");
    }

    List<FlSpot> entradas = [];
    List<FlSpot> saidas = [];

    for (int i = 0; i < mensal.length; i++) {
      entradas.add(FlSpot(i.toDouble(), (mensal[i]["entradas"] ?? 0).toDouble()));
      saidas.add(FlSpot(i.toDouble(), (mensal[i]["saidas"] ?? 0).toDouble()));
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: entradas,
              isCurved: true,
            ),
            LineChartBarData(
              spots: saidas,
              isCurved: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget listaUltimos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text("Últimos lançamentos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        ...ultimos.map((item) {
          return ListTile(
            leading: Icon(
              item["tipo"] == "entrada" ? Icons.arrow_downward : Icons.arrow_upward,
              color: item["tipo"] == "entrada" ? Colors.green : Colors.red,
            ),
            title: Text(item["descricao"] ?? ""),
            subtitle: Text(item["data"] ?? ""),
            trailing: Text("R\$ ${item["valor"]}"),
          );
        }).toList()

      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    if (carregando) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [

          Row(
            children: [
              card("Membros", "${dados["membros"]}", Icons.people, Colors.blue),
              card("Entradas", "R\$ ${dados["entradas"]}", Icons.arrow_downward, Colors.green),
            ],
          ),

          Row(
            children: [
              card("Saídas", "R\$ ${dados["saidas"]}", Icons.arrow_upward, Colors.red),
              card("Saldo", "R\$ ${dados["saldo"]}", Icons.account_balance_wallet, Colors.purple),
            ],
          ),

          SizedBox(height: 20),

          grafico(),

          SizedBox(height: 20),

          listaUltimos(),

        ],
      ),
    );
  }
}

