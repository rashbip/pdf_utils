import 'package:flutter/services.dart';

class PDFDoc {
  static const MethodChannel _channel = MethodChannel('pdf_utils');

  final String path;
  final String password;
  int? _length;
  PDFDocInfo? _info;

  PDFDoc._({required this.path, this.password = ""});

  static Future<PDFDoc> fromPath(String path, {String password = ""}) async {
    final doc = PDFDoc._(path: path, password: password);
    await doc._init();
    return doc;
  }

  Future<void> _init() async {
    try {
      final Map<dynamic, dynamic>? data = await _channel.invokeMethod('initDoc', {
        'path': path,
        'password': password,
      });
      if (data != null) {
        _length = data['length'] as int?;
        final infoMap = data['info'] as Map<dynamic, dynamic>?;
        if (infoMap != null) {
          _info = PDFDocInfo._fromMap(infoMap);
        }
      }
    } on PlatformException catch (e) {
      throw Exception("Failed to initialize PDF document: ${e.message}");
    }
  }

  int get length => _length ?? 0;
  PDFDocInfo get info => _info ?? PDFDocInfo._empty();

  Future<String> get text async {
    if (length == 0) return "";
    final List<int> pages = List.generate(length, (index) => index + 1);
    final List<dynamic>? texts = await _channel.invokeMethod('getDocText', {
      'path': path,
      'missingPagesNumbers': pages,
      'password': password,
    });
    return texts?.join("\n") ?? "";
  }

  PDFPage pageAt(int index) {
    if (index < 1 || index > length) {
      throw RangeError.index(index, this, "index", "Page index out of range", length);
    }
    return PDFPage._(this, index);
  }
}

class PDFPage {
  final PDFDoc doc;
  final int number;

  PDFPage._(this.doc, this.number);

  Future<String> get text async {
    final String? text = await PDFDoc._channel.invokeMethod('getDocPageText', {
      'path': doc.path,
      'number': number,
      'password': doc.password,
    });
    return text ?? "";
  }
}

class PDFDocInfo {
  final String? author;
  final DateTime? creationDate;
  final DateTime? modificationDate;
  final String? creator;
  final String? producer;
  final List<String> keywords;
  final String? title;
  final String? subject;

  PDFDocInfo._({
    this.author,
    this.creationDate,
    this.modificationDate,
    this.creator,
    this.producer,
    this.keywords = const [],
    this.title,
    this.subject,
  });

  factory PDFDocInfo._empty() => PDFDocInfo._();

  factory PDFDocInfo._fromMap(Map<dynamic, dynamic> map) {
    return PDFDocInfo._(
      author: map['author'] as String?,
      creationDate: _parseDate(map['creationDate']),
      modificationDate: _parseDate(map['modificationDate']),
      creator: map['creator'] as String?,
      producer: map['producer'] as String?,
      keywords: (map['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      title: map['title'] as String?,
      subject: map['subject'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null || date == "") return null;
    try {
      if (date is String) {
        // iOS returns yyyy-MM-dd hh:mm:ss
        // Android returns timestamp as string
        if (date.contains("-")) {
          return DateTime.tryParse(date);
        } else {
          final ms = int.tryParse(date);
          if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
        }
      }
    } catch (_) {}
    return null;
  }
}
