import 'package:flutter/material.dart';
import 'dart:convert';
import 'api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardEBDPage extends StatefulWidget {
  @override
  _DashboardEBDPageState createState() => _DashboardEBDPageState();
}

class _DashboardEBDPageState extends State<DashboardEBDPage> {

  Map dados = {};
  List segmentos = [];

  Future carregar() async {
    final d = await ApiService.get("/ebd/dashboard");
    final s = await ApiService.get("/ebd/grafico-segmento");

    if (d.statusCode == 200 && s.statusCode == 200) {
      setState(() {
        dados = jsonDecode(d.body);
        segmentos = jsonDecode(s.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  // ==========================
  // CARD BONITO
  // ==========================
  Widget card(String titulo, dynamic valor, Color cor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            Text(
              "${valor ?? 0}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // GRÁFICO MELHORADO
  // ==========================
  Widget grafico() {
    return Container(
      height: 250,
      padding: EdgeInsets.all(12),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= segmentos.length) return Container();
                  return Text(
                    segmentos[value.toInt()]["segmento"],
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          barGroups: segmentos.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: (e.value["total"] ?? 0).toDouble(),
                  borderRadius: BorderRadius.circular(4),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [

          SizedBox(height: 10),

          // 🔥 CARDS
          Row(
            children: [
              card("Total", dados["total"], Colors.blue),
              card("Hoje", dados["presentes"], Colors.green),
            ],
          ),

          Row(
            children: [
              card("Frequência", "${dados["frequencia"] ?? 0}%", Colors.orange),
              card("Ausentes", dados["ausentes"], Colors.red),
            ],
          ),

          SizedBox(height: 20),

          // 🔥 TÍTULO
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Presença por Segmento",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(height: 10),

          grafico(),

        ],
      ),
    );
  }
}


