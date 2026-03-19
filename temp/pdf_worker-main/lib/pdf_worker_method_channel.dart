import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pdf_worker_platform_interface.dart';

/// An implementation of [PdfWorkerPlatform] that uses method channels.
class MethodChannelPdfWorker extends PdfWorkerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pdf_worker');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> isEncrypted({required String filePath}) async {
    try {
      final bool result = await methodChannel.invokeMethod('isEncrypted', {
        'filePath': filePath,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to check if PDF is encrypted: '${e.message}'.");
      }
      rethrow;
    }
  }

  @override
  Future<bool> isEncryptedByTail({required String filePath}) async {
    try {
      final bool result = await methodChannel.invokeMethod('isEncryptedByTail', {
        'filePath': filePath,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to check if PDF is encrypted by tail: '${e.message}'.");
      }
      rethrow;
    }
  }

  @override
  Future<void> lock({required String filePath, required String userPassword, required String ownerPassword}) async {
    try {
      await methodChannel.invokeMethod('lock', {
        'filePath': filePath,
        'userPassword': userPassword,
        'ownerPassword': ownerPassword,
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to lock PDF: '${e.message}'.");
      }
      rethrow;
    }
  }

  @override
  Future<bool> unlock({required String filePath, required String password}) async {
    try {
      final bool result = await methodChannel.invokeMethod('unlock', {
        'filePath': filePath,
        'password': password,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to unlock PDF: '${e.message}'.");
      }
      rethrow;
    }
  }

  @override
  Future<String?>choosePagesIndexToMerge({required String inputPath, required String outputPath, required List<int> pagesIndex}) async {
    try {
      final String? result = await methodChannel.invokeMethod('choosePagesIndexToMerge', {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'pagesIndex': pagesIndex,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to choose pages to merge PDF: '${e.message}'.");
      }
      rethrow;
    }
  }

  @override
  Future<String>mergePdfFiles({required List<String> filesPath, required String outputPath}) async {
    try {
      final String result = await methodChannel.invokeMethod('mergePdfFiles', {
        'filesPath': filesPath,
        'outputPath': outputPath,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to merge PDF files: '${e.message}'.");
      }
      rethrow;
    }
  }

  @override
  Future<String>mergeImagesToPdf({required List<String> imagesPath, required String outputPath, Map<String, dynamic>? config}) async {
    try {
      final String result = await methodChannel.invokeMethod('mergeImagesToPdf', {
        'imagesPath': imagesPath,
        'outputPath': outputPath,
        'config': config,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to merge images to PDF: '${e.message}'.");
      }
      rethrow;
    }
  }

  @override
  Future<List<String>>pdfToImages({required String inputPath, required String outputDirectory, Map<String, dynamic>? config}) async {
    try {
      final result = await methodChannel.invokeListMethod<String>('pdfToImages', {
        'inputPath': inputPath,
        'outputDirectory': outputDirectory,
        'config': config,
      });
      return result ?? <String>[];
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to convert PDF to images: '${e.message}'.");
      }
      rethrow;
    }
  }

  @override
  Future<String>pdfToLongImage({required String inputPath, required String outputPath, Map<String, dynamic>? config}) async {
    try {
      final String result = await methodChannel.invokeMethod('pdfToLongImage', {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'config': config,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to convert PDF to long image: '${e.message}'.");
      }
      rethrow;
    }
  }
}
