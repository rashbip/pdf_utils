import 'dart:io';
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

/// Model representing PDF validity and protection status.
class PdfValidity {
  final bool isValid;
  final bool isOwnerPasswordProtected;
  final bool isOpenPasswordProtected;
  final bool isPrintingAllowed;
  final bool isModifyContentsAllowed;

  PdfValidity({
    required this.isValid,
    required this.isOwnerPasswordProtected,
    required this.isOpenPasswordProtected,
    required this.isPrintingAllowed,
    required this.isModifyContentsAllowed,
  });

  factory PdfValidity.fromList(List<dynamic> list) {
    return PdfValidity(
      isValid: list[0] as bool,
      isOwnerPasswordProtected: list[1] as bool,
      isOpenPasswordProtected: list[2] as bool,
      isPrintingAllowed: list[3] as bool,
      isModifyContentsAllowed: list[4] as bool,
    );
  }

  @override
  String toString() {
    return 'PdfValidity(isValid: $isValid, protected: $isOpenPasswordProtected, printing: $isPrintingAllowed)';
  }
}

/// Model representing PDF page dimensions.
class PdfPageSize {
  final int pageNumber;
  final double width;
  final double height;

  PdfPageSize({
    required this.pageNumber,
    required this.width,
    required this.height,
  });

  factory PdfPageSize.fromList(List<dynamic> list) {
    return PdfPageSize(
      pageNumber: (list[0] as double).toInt(),
      width: list[1] as double,
      height: list[2] as double,
    );
  }
}

/// A utility class for advanced PDF operations. Version 3.0.0.
class PdfUtils {
  static const MethodChannel _channel = MethodChannel('pdf_utils');

  /// Splits a PDF into multiple files, each having at most [pageCount] pages.
  static Future<List<File>> splitPdfByPageCount({
    required String filePath,
    int pageCount = 1,
  }) async {
    final List<dynamic>? resultPaths = await _channel.invokeMethod('splitPdfByPageCount', {
      'filePath': filePath,
      'pageCount': pageCount,
    });
    return resultPaths?.map((path) => File(path as String)).toList() ?? [];
  }

  /// Splits a PDF at the specified [pageNumbers].
  static Future<List<File>> splitPdfByPageNumbers({
    required String filePath,
    required List<int> pageNumbers,
  }) async {
    final List<dynamic>? resultPaths = await _channel.invokeMethod('splitPdfByPageNumbers', {
      'filePath': filePath,
      'pageNumbers': pageNumbers,
    });
    return resultPaths?.map((path) => File(path as String)).toList() ?? [];
  }

  /// Manipulates pages of a PDF: reorder, delete, or rotate.
  static Future<File?> manipulatePages({
    required String filePath,
    List<int> reorder = const [],
    List<int> delete = const [],
    Map<int, int> rotate = const {},
  }) async {
    final List<Map<String, int>> rotateList = rotate.entries.map((e) => {
      'pageNumber': e.key,
      'rotationAngle': e.value,
    }).toList();

    final String? resultPath = await _channel.invokeMethod('handlePageManipulation', {
      'filePath': filePath,
      'reorder': reorder,
      'delete': delete,
      'rotate': rotateList,
    });
    return resultPath != null ? File(resultPath) : null;
  }

  /// Compresses a PDF file by reducing image quality and scaling.
  static Future<File?> compressPdf({
    required String filePath,
    int quality = 80,
    double scale = 1.0,
    bool unEmbedFonts = false,
  }) async {
    final String? resultPath = await _channel.invokeMethod('compressPdf', {
      'filePath': filePath,
      'quality': quality,
      'scale': scale,
      'unEmbedFonts': unEmbedFonts,
    });
    return resultPath != null ? File(resultPath) : null;
  }

  /// Adds a text watermark to a PDF file.
  static Future<File?> watermarkPdf({
    required String filePath,
    required String text,
    double fontSize = 40.0,
    String layer = 'OverContent',
    double opacity = 0.3,
    double rotation = 45.0,
    String color = '#000000',
    String position = 'Center',
  }) async {
    final String? resultPath = await _channel.invokeMethod('watermarkPdf', {
      'filePath': filePath,
      'text': text,
      'fontSize': fontSize,
      'layer': layer,
      'opacity': opacity,
      'rotation': rotation,
      'color': color,
      'position': position,
    });
    return resultPath != null ? File(resultPath) : null;
  }

  /// Gets validity and protection information about a PDF.
  static Future<PdfValidity?> getValidity(String filePath, {String password = ""}) async {
    final List<dynamic>? result = await _channel.invokeMethod('getValidityAndProtection', {
      'filePath': filePath,
      'password': password,
    });
    return result != null ? PdfValidity.fromList(result) : null;
  }

  /// Encrypts a PDF with advanced permissions.
  static Future<File?> encryptPdf({
    required String filePath,
    String ownerPassword = "",
    String userPassword = "",
    bool allowPrinting = true,
    bool allowModifyContents = true,
    bool allowCopy = true,
    bool allowModifyAnnotations = true,
    bool allowFillIn = true,
    bool allowScreenReaders = true,
    bool allowAssembly = true,
    bool allowDegradedPrinting = true,
    bool useAes128 = true,
  }) async {
    final String? resultPath = await _channel.invokeMethod('encryptPdf', {
      'filePath': filePath,
      'ownerPassword': ownerPassword,
      'userPassword': userPassword,
      'permissions': {
        'allowPrinting': allowPrinting,
        'allowModifyContents': allowModifyContents,
        'allowCopy': allowCopy,
        'allowModifyAnnotations': allowModifyAnnotations,
        'allowFillIn': allowFillIn,
        'allowScreenReaders': allowScreenReaders,
        'allowAssembly': allowAssembly,
        'allowDegradedPrinting': allowDegradedPrinting,
        'aes128': useAes128,
      }
    });
    return resultPath != null ? File(resultPath) : null;
  }

  /// Decrypts a PDF file.
  static Future<File?> decryptPdf(String filePath, {String password = ""}) async {
    final String? resultPath = await _channel.invokeMethod('decryptPdf', {
      'filePath': filePath,
      'password': password,
    });
    return resultPath != null ? File(resultPath) : null;
  }

  /// Gets the sizes of all pages in a PDF.
  static Future<List<PdfPageSize>> getPagesSize(String filePath) async {
    final List<dynamic>? result = await _channel.invokeMethod('getPagesSize', {
      'filePath': filePath,
    });
    return result?.map((item) => PdfPageSize.fromList(item as List)).toList() ?? [];
  }

  /// Merges multiple PDFs into one using high-performance native implementation.
  static Future<File?> mergePdfs(List<String> filesPath) async {
    final String? resultPath = await _channel.invokeMethod('mergePdfs', {
      'filesPath': filesPath,
    });
    return resultPath != null ? File(resultPath) : null;
  }

  /// Converts a list of images into one or more PDF files using native implementation.
  static Future<List<File>> imagesToPdfs({
    required List<String> imagesPath,
    bool createSinglePdf = true,
  }) async {
    final List<dynamic>? resultPaths = await _channel.invokeMethod('nativeImagesToPdf', {
      'imagesPath': imagesPath,
      'createSingle': createSinglePdf,
    });
    return resultPaths?.map((path) => File(path as String)).toList() ?? [];
  }

  /// Converts a PDF to a series of images.
  static Future<List<String>> pdfToImages({
    required String pdfPath,
    required String outputDirectory,
    String? password,
  }) async {
    final dir = Directory(outputDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
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
  }

  /// Converts a PDF to a single long image.
  static Future<File?> pdfToLongImage({
    required String pdfPath,
    required String outputPath,
    String password = "",
  }) async {
    final String? resultPath = await _channel.invokeMethod('pdfToLongImage', {
      'inputPath': pdfPath,
      'outputPath': outputPath,
      'config': {
        'imgFormat': 'jpg',
        'quality': 90,
      },
      'password': password,
    });
    return resultPath != null ? File(resultPath) : null;
  }

  // --- Legacy / Text Related Methods (Still using PDFBox-based PDFDoc for robust text extraction) ---

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

  /// Adds a page (image or another PDF) to an existing PDF at a specific location.
  /// [index] is 0-based. Use [beforePage] or [afterPage] (1-based) for convenience.
  static Future<File?> addPage({
    required String filePath,
    required String insertPath,
    int? index,
    int? beforePage,
    int? afterPage,
  }) async {
    int targetIndex = index ?? 0;
    if (beforePage != null) targetIndex = beforePage - 1;
    if (afterPage != null) targetIndex = afterPage;

    final String? resultPath = await _channel.invokeMethod('addPage', {
      'filePath': filePath,
      'insertPath': insertPath,
      'index': targetIndex,
    });
    return resultPath != null ? File(resultPath) : null;
  }

  /// Resizes pages of a PDF to a target [width] and [height], while maintaining aspect ratio and centering the content.
  /// If [pages] is null, all pages are resized.
  static Future<File?> resizePdf({
    required String filePath,
    required double width,
    required double height,
    List<int>? pages,
  }) async {
    final String? resultPath = await _channel.invokeMethod('resizePdf', {
      'filePath': filePath,
      'width': width,
      'height': height,
      'pages': pages,
    });
    return resultPath != null ? File(resultPath) : null;
  }
}
