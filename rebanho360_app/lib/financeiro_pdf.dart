import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future gerarPDF(List dados) async {

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {

        return pw.Column(
          children: [

            pw.Text("Relatório Financeiro",
                style: pw.TextStyle(fontSize: 20)),

            pw.SizedBox(height: 20),

            ...dados.map((item) {
              return pw.Text(
                "${item["mes"]} | Entradas: ${item["entradas"]} | Saídas: ${item["saidas"]}",
              );
            })

          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
  );
}
