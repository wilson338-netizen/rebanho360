import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class QRScannerPage extends StatelessWidget {

  final int pgId;

  QRScannerPage({required this.pgId});

  void registrarPresenca(String codigo) async {

    if (!codigo.contains("MEMBRO:")) return;

    final id = codigo.split(":")[1];

    await http.post(
      Uri.parse("http://localhost:8000/presenca_qr"),
      headers: {"Content-Type": "application/json"},
      body: '{"membro_id": $id, "pg_id": $pgId}',
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Escanear Presença")),

      body: MobileScanner(
        onDetect: (barcode, args) {
          final String? code = barcode.rawValue;

          if (code != null) {
            registrarPresenca(code);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
