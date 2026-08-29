import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:booth_admin/models/printable.dart';

class PrintService {
  static const double _hagakiWidthInches = 3.94;
  static const double _hagakiHeightInches = 5.83;
  static const double _centerBorderWidth = 3;
  static const int _photosPerPage = 2;

  static Future<bool> printPrintable(Printable printable) async {
    if (printable.imageUrl.isEmpty) {
      throw Exception('This printable does not have an image URL.');
    }

    final response = await http.get(Uri.parse(printable.imageUrl));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to download the printable image.');
    }

    final image = pw.MemoryImage(response.bodyBytes);
    final totalPhotos =
        (printable.amountToPrint < 1 ? 1 : printable.amountToPrint) *
            (printable.pages < 1 ? 1 : printable.pages) *
            (printable.copies < 1 ? 1 : printable.copies);
    final pageCount = (totalPhotos / _photosPerPage).ceil();
    const pageFormat = PdfPageFormat(
      _hagakiWidthInches * PdfPageFormat.inch,
      _hagakiHeightInches * PdfPageFormat.inch,
    );

    return Printing.layoutPdf(
      onLayout: (format) async {
        final document = pw.Document();
        for (var index = 0; index < pageCount; index++) {
          final firstPhotoIndex = index * _photosPerPage;
          document.addPage(
            pw.Page(
              pageFormat: pageFormat,
              margin: pw.EdgeInsets.zero,
              build: (_) => pw.SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Expanded(
                      child: pw.Center(
                        child: pw.Image(image, fit: pw.BoxFit.fill),
                      ),
                    ),
                    if (firstPhotoIndex + 1 < totalPhotos) ...[
                      pw.Container(
                        width: _centerBorderWidth,
                        color: PdfColors.white,
                      ),
                      pw.Expanded(
                        child: pw.Center(
                          child: pw.Image(image, fit: pw.BoxFit.fill),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }
        return document.save();
      },
    );
  }
}
