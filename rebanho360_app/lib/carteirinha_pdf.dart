import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future gerarPDF(Map dados) async {

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Container(
          padding: pw.EdgeInsets.all(20),
          child: pw.Column(
            children: [

              pw.Text("Rebanho360",
                  style: pw.TextStyle(fontSize: 20)),

              pw.SizedBox(height: 10),

              pw.Text(dados["nome"]),

              pw.Text(dados["cargo"]),

              pw.SizedBox(height: 20),

              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: "MEMBRO:${dados["id"]}",
                width: 100,
                height: 100,
              ),

            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) => pdf.save(),
  );
}
