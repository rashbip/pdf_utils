import 'dart:io';
import 'package:pdf/pdf.dart' as pdf_lib;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_worker/pdf_worker.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';

export 'invoice_generator.dart';
export 'model/invoice.dart';
export 'model/customer.dart';
export 'model/supplier.dart';
export 'pdf_viewer.dart';
export 'package:pdfx/pdfx.dart'
    show PdfController, PdfControllerPinch, PdfDocument;

/// A utility class for common PDF operations like image conversion and extraction.
class PdfUtils {
  /// Converts a list of image paths into a single PDF file.
  /// 
  /// [imagePaths] is a list of absolute paths to the images.
  /// [outputFileName] is the desired name for the generated PDF (without extension).
  /// [format] defaults to A4.
  /// 
  /// Returns a [File] object pointing to the generated PDF in the temporary directory.
  static Future<File> imagesToPdf({
    required List<String> imagePaths,
    required String outputFileName,
    pdf_lib.PdfPageFormat format = pdf_lib.PdfPageFormat.a4,
    String? userPassword,
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

    if (userPassword != null && userPassword.isNotEmpty) {
      await PdfWorker().lock(
        filePath: file.path,
        userPassword: userPassword,
        ownerPassword: userPassword,
      );
    }

    return file;
  }

  /// Extracts all pages from a PDF as images (JPEGs).
  /// 
  /// [pdfPath] is the absolute path to the PDF file.
  /// [outputDirectory] is the directory where the images will be saved.
  /// [onProgress] is an optional callback that returns (current, total) page count.
  /// 
  /// Returns a list of paths to the extracted image files.
  static Future<List<String>> pdfToImages({
    required String pdfPath,
    required String outputDirectory,
    String? password,
    Function(int current, int total)? onProgress,
  }) async {
    final List<String> imagePaths = [];
    String effectivePath = pdfPath;
    File? tempFile;

    try {
      if (password != null && password.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = p.join(
          tempDir.path,
          'temp_unlock_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        tempFile = await File(pdfPath).copy(tempPath);
        await PdfWorker().unlock(filePath: tempFile.path, password: password);
        effectivePath = tempFile.path;
      }

      final document = await pdfx.PdfDocument.openFile(effectivePath);

      final dir = Directory(outputDirectory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      for (int i = 1; i <= document.pagesCount; i++) {
        onProgress?.call(i, document.pagesCount);
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width * 2, // Scale up for better quality
          height: page.height * 2,
          format: pdfx.PdfPageImageFormat.jpeg,
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
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }

    return imagePaths;
  }

  /// Adds password protection to an existing PDF.
  static Future<File> protectPdf({
    required String inputPath,
    required String password,
    required String outputFileName,
  }) async {
    final outputDir = await getTemporaryDirectory();
    final outputFile = File(p.join(outputDir.path, '$outputFileName.pdf'));

    // Copy input to output first so we don't modify the original if needed
    await File(inputPath).copy(outputFile.path);

    await PdfWorker().lock(
      filePath: outputFile.path,
      userPassword: password,
      ownerPassword: password,
    );
    return outputFile;
  }

  /// Removes password protection from an existing PDF.
  static Future<File> unlockPdf({
    required String inputPath,
    required String password,
    required String outputFileName,
  }) async {
    final outputDir = await getTemporaryDirectory();
    final outputFile = File(p.join(outputDir.path, '$outputFileName.pdf'));

    // Copy input to output first
    await File(inputPath).copy(outputFile.path);

    await PdfWorker().unlock(filePath: outputFile.path, password: password);
    return outputFile;
  }

  /// Extracts the full text from a PDF.
  static Future<String> getFullText(String pdfPath) async {
    final doc = await PDFDoc.fromPath(pdfPath);
    return await doc.text;
  }

  /// Extracts text from a specific page of a PDF.
  static Future<String> getPageText(String pdfPath, int pageNumber) async {
    final doc = await PDFDoc.fromPath(pdfPath);
    if (pageNumber > 0 && pageNumber <= doc.length) {
      return await doc.pageAt(pageNumber).text;
    }
    return "";
  }

  /// Extracts text from a range of pages in a PDF.
  static Future<String> getRangeText(
    String pdfPath, {
    required int start,
    required int end,
  }) async {
    final doc = await PDFDoc.fromPath(pdfPath);
    String fullResult = "";
    for (int i = start; i <= end; i++) {
      if (i > 0 && i <= doc.length) {
        final text = await doc.pageAt(i).text;
        fullResult += "--- Page $i ---\n$text\n\n";
      }
    }
    return fullResult;
  }

  /// Gets the number of pages in a PDF.
  static Future<int> getPageCount(String pdfPath) async {
    final doc = await PDFDoc.fromPath(pdfPath);
    return doc.length;
  }

  /// Gets the metadata info of a PDF.
  static Future<Map<String, dynamic>> getDocInfo(String pdfPath) async {
    final doc = await PDFDoc.fromPath(pdfPath);
    final info = doc.info;
    return {
      "author": info.author,
      "creationDate": info.creationDate?.toIso8601String(),
      "modificationDate": info.modificationDate?.toIso8601String(),
      "creator": info.creator,
      "producer": info.producer,
      "keywords": info.keywords,
      "title": info.title,
      "subject": info.subject,
    };
  }
}
