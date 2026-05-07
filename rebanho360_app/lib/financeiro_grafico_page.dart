import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

import 'package:rebanho360_app/api_service.dart';

final String baseUrl = "${ApiService.baseUrl}";



class FinanceiroGraficoPage extends StatefulWidget {
  @override
  _FinanceiroGraficoPageState createState() =>
      _FinanceiroGraficoPageState();
}

class _FinanceiroGraficoPageState
    extends State<FinanceiroGraficoPage> {

  List dados = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future carregar() async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/financeiro/mensal"),
    );

    if (response.statusCode == 200) {
      setState(() {
        dados = jsonDecode(response.body);
      });
    }
  }

  List<FlSpot> gerar(String campo) {
    return dados.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        (e.value[campo] ?? 0).toDouble(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gráfico Financeiro"),
      ),
      body: dados.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // 🔥 LEGENDA
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Entradas (verde) | Saídas (vermelho) | Saldo (azul) | Dízimos (roxo) | Ofertas (laranja)",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: LineChart(
                      LineChartData(

                        // 🔥 EIXO COM MESES
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= dados.length) {
                                  return Container();
                                }
                                return Text(
                                  dados[value.toInt()]["mes"],
                                  style: TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),

                        borderData: FlBorderData(show: true),

                        // 🔥 TODAS AS LINHAS DO GRÁFICO
                        lineBarsData: [

                          // ENTRADAS
                          LineChartBarData(
                            spots: gerar("entradas"),
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                          ),

                          // SAÍDAS
                          LineChartBarData(
                            spots: gerar("saidas"),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                          ),

                          // SALDO
                          LineChartBarData(
                            spots: gerar("saldo"),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                          ),

                          // DÍZIMOS
                          LineChartBarData(
                            spots: gerar("dizimos"),
                            isCurved: true,
                            color: Colors.purple,
                            barWidth: 2,
                          ),

                          // OFERTAS
                          LineChartBarData(
                            spots: gerar("ofertas"),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 2,
                          ),

                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
    );
  }
}
