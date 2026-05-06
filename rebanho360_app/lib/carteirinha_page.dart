// ==========================================
// 1 IMPORTAÇÕES
// ==========================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

import 'api_service.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';


// ==========================================
// 2 WIDGET
// ==========================================

class CarteirinhaPage extends StatefulWidget {
  final int membroId;

  CarteirinhaPage({required this.membroId});

  @override
  _CarteirinhaPageState createState() => _CarteirinhaPageState();
}


// ==========================================
// 3 STATE
// ==========================================

class _CarteirinhaPageState extends State<CarteirinhaPage> {

  Map dados = {};
  bool loading = true;


// ==========================================
// 4 INIT
// ==========================================

  @override
  void initState() {
    super.initState();
    carregar();
  }


// ==========================================
// 5 CARREGAR DADOS
// ==========================================

 Future carregar() async {

  final response = await ApiService.get(
    "/carteirinha/${widget.membroId}"
  );

  if (response.statusCode == 200) {
    setState(() {
      dados = jsonDecode(response.body);
      loading = false;
    });
  }
}


// ==========================================
// 6 COR POR CARGO (CORRIGIDO)
// ==========================================

Color corPorCargo(String cargo) {

  cargo = cargo.toLowerCase();

  if (cargo.contains("pastor")) {
    return Colors.black;
  }

  if (cargo.contains("presbítero") ||
      cargo.contains("missionário") ||
      cargo.contains("evangelista")) {
    return Color(0xFFE5E4E2); // Platinum
  }

  if (cargo.contains("diácono") || cargo.contains("diaconisa")) {
    return Colors.purple; // Lilás
  }

  return Colors.blue; // Membro
}


// ==========================================
// COR DO TEXTO (IMPORTANTE)
// ==========================================

Color textoCor(String cargo) {

  cargo = cargo.toLowerCase();

  if (cargo.contains("presbítero") ||
      cargo.contains("missionário") ||
      cargo.contains("evangelista")) {
    return Colors.black;
  }

  return Colors.white;
}


// ==========================================
// 7 GERAR PDF
// ==========================================

Future gerarPDF() async {

  final pdf = pw.Document();

  PdfColor corCargo(String cargo) {

    cargo = cargo.toLowerCase();

    if (cargo.contains("pastor")) {
      return PdfColor.fromInt(0xFF000000);
    }

    if (cargo.contains("presbítero") ||
        cargo.contains("missionário") ||
        cargo.contains("evangelista")) {
      return PdfColor.fromInt(0xFFE5E4E2);
    }

    if (cargo.contains("diácono") || cargo.contains("diaconisa")) {
      return PdfColor.fromInt(0xFF9C27B0);
    }

    return PdfColor.fromInt(0xFF1565C0);
  }

  final cor = corCargo(dados["cargo"] ?? "");

  pdf.addPage(
    pw.Page(
      build: (context) {

        return pw.Center(
          child: pw.Container(
            width: 320,
            height: 190,
            padding: pw.EdgeInsets.all(16),

            decoration: pw.BoxDecoration(
              color: cor,
              borderRadius: pw.BorderRadius.circular(16),
            ),

            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "REBANHO360",
                      style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFFFFFFFF),
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      "ID ${dados["id"]}",
                      style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),

                pw.Text(
                  dados["nome"] ?? "",
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.Text(
                  dados["cargo"] ?? "",
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFFDDDDDD),
                  ),
                ),

                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: "MEMBRO:${dados["id"]}",
                  width: 60,
                  height: 60,
                ),

              ],
            ),
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) => pdf.save(),
  );
}


// ==========================================
// 8 UI
// ==========================================

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final cargo = dados["cargo"] ?? "";
    final cor = corPorCargo(cargo);
    final corTexto = textoCor(cargo);

    return Scaffold(

      appBar: AppBar(
        title: Text("Carteirinha"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: gerarPDF,
          )
        ],
      ),

      body: Center(

        child: Container(
          width: 320,
          height: 200,
          padding: EdgeInsets.all(16),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cor,
                cor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: Offset(0, 4),
              )
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "REBANHO360",
                    style: TextStyle(
                      color: corTexto,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.church, color: corTexto)
                ],
              ),

              Spacer(),

              Text(
                dados["nome"] ?? "",
                style: TextStyle(
                  color: corTexto,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                dados["cargo"] ?? "",
                style: TextStyle(
                  color: corTexto.withOpacity(0.7),
                ),
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  QrImageView(
                    data: "MEMBRO:${dados["id"]}",
                    size: 60,
                    backgroundColor: Colors.white,
                  ),

                  CircleAvatar(
                    radius: 25,
                    backgroundImage: dados["foto"] != null && dados["foto"] != ""
                        ? NetworkImage("http://localhost:8000/${dados["foto"]}")
                        : null,
                    child: (dados["foto"] == null || dados["foto"] == "")
                        ? Icon(Icons.person)
                        : null,
                  ),

                ],
              ),

            ],
          ),
        ),

      ),
    );
  }
}

