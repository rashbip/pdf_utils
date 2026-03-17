import 'dart:io';
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PdfUtils {
  /// Converts a list of image paths into a single PDF file.
  static Future<File> imagesToPdf({
    required List<String> imagePaths,
    required String outputFileName,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();

    for (final path in imagePaths) {
      final image = pw.MemoryImage(File(path).readAsBytesSync());
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
          },
        ),
      );
    }

    final outputDir = await getTemporaryDirectory();
    final file = File(p.join(outputDir.path, '$outputFileName.pdf'));
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Extracts all pages from a PDF as images (JPEGs).
  /// Returns a list of paths to the extracted images.
  static Future<List<String>> pdfToImages({
    required String pdfPath,
    required String outputDirectory,
  }) async {
    final List<String> imagePaths = [];
    final document = await PdfDocument.openFile(pdfPath);

    final dir = Directory(outputDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2, // Scale up for better quality
        height: page.height * 2,
        format: PdfPageImageFormat.jpeg,
        quality: 90,
      );

      if (pageImage != null) {
        final imageName =
            'extracted_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final imagePath = p.join(outputDirectory, imageName);
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(pageImage.bytes);
        imagePaths.add(imagePath);
      }
      await page.close();
    }

    await document.close();
    return imagePaths;
  }
}
