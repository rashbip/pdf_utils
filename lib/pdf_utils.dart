import 'dart:io';
import 'package:pdf/pdf.dart' as pdf_lib;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'pdf_doc.dart';

export 'invoice_generator.dart';
export 'model/invoice.dart';
export 'model/customer.dart';
export 'model/supplier.dart';
export 'pdf_viewer.dart';
export 'pdf_doc.dart';
export 'package:pdfx/pdfx.dart'
    show PdfController, PdfControllerPinch, PdfDocument;

/// A utility class for common PDF operations like image conversion and extraction.
class PdfUtils {
  static const MethodChannel _channel = MethodChannel('pdf_utils');

  /// Converts a list of image paths into a single PDF file using the `pdf` package.
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
      await protectPdf(
        inputPath: file.path, 
        password: userPassword, 
        outputFileName: outputFileName
      );
    }

    return file;
  }

  /// Extracts all pages from a PDF as images (JPEGs) using native `PdfRenderer`.
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
    final dir = Directory(outputDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    try {
      final List<dynamic>? imagePaths = await _channel.invokeMethod('pdfToImages', {
        'inputPath': pdfPath,
        'outputDirectory': outputDirectory,
        'config': {
          'imgFormat': 'jpg',
          'quality': 90,
        },
        'password': password ?? "", 
      });
      
      return imagePaths?.cast<String>() ?? [];
    } catch (e) {
      // Fallback to pdfx if native fails or for backwards compatibility
      final List<String> paths = [];
      final document = await pdfx.PdfDocument.openFile(pdfPath);
      for (int i = 1; i <= document.pagesCount; i++) {
        onProgress?.call(i, document.pagesCount);
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: pdfx.PdfPageImageFormat.jpeg,
          quality: 90,
        );
        if (pageImage != null) {
          final imageName = 'extracted_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final imagePath = p.join(outputDirectory, imageName);
          await File(imagePath).writeAsBytes(pageImage.bytes);
          paths.add(imagePath);
        }
        await page.close();
      }
      await document.close();
      return paths;
    }
  }

  /// Adds password protection to an existing PDF using native implementation.
  static Future<File> protectPdf({
    required String inputPath,
    required String password,
    required String outputFileName,
  }) async {
    final outputDir = await getTemporaryDirectory();
    final outputFile = File(p.join(outputDir.path, '$outputFileName.pdf'));

    if (inputPath != outputFile.path) {
      await File(inputPath).copy(outputFile.path);
    }

    await _channel.invokeMethod('lock', {
      'filePath': outputFile.path,
      'userPassword': password,
      'ownerPassword': password,
    });
    return outputFile;
  }

  /// Removes password protection from an existing PDF using native implementation.
  static Future<File> unlockPdf({
    required String inputPath,
    required String password,
    required String outputFileName,
  }) async {
    final outputDir = await getTemporaryDirectory();
    final outputFile = File(p.join(outputDir.path, '$outputFileName.pdf'));

    if (inputPath != outputFile.path) {
      await File(inputPath).copy(outputFile.path);
    }

    await _channel.invokeMethod('unlock', {
      'filePath': outputFile.path,
      'password': password,
    });
    return outputFile;
  }

  /// Checks if a PDF is encrypted.
  static Future<bool> isEncrypted(String pdfPath) async {
    return await _channel.invokeMethod('isEncrypted', {
      'filePath': pdfPath,
    });
  }

  /// Merges multiple PDF files into one.
  static Future<File> mergePdfFiles({
    required List<String> filesPath,
    required String outputFileName,
  }) async {
    final outputDir = await getTemporaryDirectory();
    final outputFile = File(p.join(outputDir.path, '$outputFileName.pdf'));

    final String? resultPath = await _channel.invokeMethod('mergePdfFiles', {
      'filesPath': filesPath,
      'outputPath': outputFile.path,
    });
    
    return File(resultPath ?? outputFile.path);
  }

  /// Chooses specific pages from a PDF and merges them into a new one.
  static Future<File> choosePagesIndexToMerge({
    required String inputPath,
    required List<int> pagesIndex,
    required String outputFileName,
  }) async {
    final outputDir = await getTemporaryDirectory();
    final outputFile = File(p.join(outputDir.path, '$outputFileName.pdf'));

    final String? resultPath = await _channel.invokeMethod('choosePagesIndexToMerge', {
      'inputPath': inputPath,
      'outputPath': outputFile.path,
      'pagesIndex': pagesIndex,
    });
    
    return File(resultPath ?? outputFile.path);
  }

  /// Converts images to PDF using native highly optimized implementation.
  static Future<File> nativeImagesToPdf({
    required List<String> imagePaths,
    required String outputFileName,
    int? maxWidth,
    int? maxHeight,
    bool keepAspectRatio = true,
  }) async {
    final outputDir = await getTemporaryDirectory();
    final outputFile = File(p.join(outputDir.path, '$outputFileName.pdf'));

    final String? resultPath = await _channel.invokeMethod('mergeImagesToPdf', {
      'imagesPath': imagePaths,
      'outputPath': outputFile.path,
      'config': {
        'rescale': {
          'maxWidth': maxWidth ?? 0,
          'maxHeight': maxHeight ?? 0,
        },
        'keepAspectRatio': keepAspectRatio,
      }
    });

    return File(resultPath ?? outputFile.path);
  }

  /// Converts a PDF to a single long image.
  static Future<File> pdfToLongImage({
    required String pdfPath,
    required String outputFileName,
    String password = "",
  }) async {
    final outputDir = await getTemporaryDirectory();
    final outputFile = File(p.join(outputDir.path, '$outputFileName.jpg'));

    final String? resultPath = await _channel.invokeMethod('pdfToLongImage', {
      'inputPath': pdfPath,
      'outputPath': outputFile.path,
      'config': {
        'imgFormat': 'jpg',
        'quality': 90,
      },
      'password': password,
    });

    return File(resultPath ?? outputFile.path);
  }

  /// Extracts the full text from a PDF.
  static Future<String> getFullText(String pdfPath, {String password = ""}) async {
    final doc = await PDFDoc.fromPath(pdfPath, password: password);
    return await doc.text;
  }

  /// Extracts text from a specific page of a PDF.
  static Future<String> getPageText(String pdfPath, int pageNumber, {String password = ""}) async {
    final doc = await PDFDoc.fromPath(pdfPath, password: password);
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
    String password = "",
  }) async {
    final doc = await PDFDoc.fromPath(pdfPath, password: password);
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
  static Future<int> getPageCount(String pdfPath, {String password = ""}) async {
    final doc = await PDFDoc.fromPath(pdfPath, password: password);
    return doc.length;
  }

  /// Gets the metadata info of a PDF.
  static Future<Map<String, dynamic>> getDocInfo(String pdfPath, {String password = ""}) async {
    final doc = await PDFDoc.fromPath(pdfPath, password: password);
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
