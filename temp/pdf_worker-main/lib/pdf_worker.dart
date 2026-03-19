
import 'package:pdf_worker/models/pdf_to_images_config.dart';

import 'models/images_to_pdf_config.dart';
import 'pdf_worker_platform_interface.dart';
export 'models/images_to_pdf_config.dart';
export 'models/pdf_to_images_config.dart';
class PdfWorker {
  Future<String?> getPlatformVersion() {
    return PdfWorkerPlatform.instance.getPlatformVersion();
  }

  // need try catch, if path is not exist, it will throw exception
  // filePath: the path of pdf file on your device, not flutter assets path
  Future<bool> isEncryptedByTail({required String filePath}) {
    return PdfWorkerPlatform.instance.isEncryptedByTail(filePath: filePath);
  }

  // need try catch, if path is not exist, it will throw exception
  Future<bool> isEncrypted({required String filePath}) {
    return PdfWorkerPlatform.instance.isEncrypted(filePath: filePath);
  }

  // need try catch, if path is not exist, it will throw exception
  Future<void> lock({required String filePath, required String userPassword, required String ownerPassword}) async {
     await PdfWorkerPlatform.instance.lock(filePath: filePath, userPassword: userPassword, ownerPassword: ownerPassword);
  }

  // need try catch, if path is not exist, it will throw exception
  Future<bool> unlock({required String filePath, required String password}) {
    return PdfWorkerPlatform.instance.unlock(filePath: filePath, password: password);
  }
  
  // split
  // choose pages to merge a new pdf
  Future<String?>choosePagesIndexToMerge({required String inputPath, required String outputPath, required List<int> pagesIndex}) {
    return PdfWorkerPlatform.instance.choosePagesIndexToMerge(inputPath: inputPath, outputPath: outputPath, pagesIndex: pagesIndex);
  }
    
  // merge
  // make multiple pdf to one pdf
  Future<String>mergePdfFiles({required List<String> filesPath, required String outputPath}) {
    return PdfWorkerPlatform.instance.mergePdfFiles(filesPath: filesPath, outputPath: outputPath);
  }

  // make multiple images to one pdf
  Future<String>mergeImagesToPdf({
    required List<String> imagesPath,
    required String outputPath,
    ImagesToPdfConfig? config,
  }) {
    return PdfWorkerPlatform.instance.mergeImagesToPdf(
      imagesPath: imagesPath,
      outputPath: outputPath,
      config: config?.toJson() ?? ImagesToPdfConfig.a4Config().toJson(),
    );
  }

  // pdf to images
  Future<List<String>>pdfToImages({required String inputPath, required String outputDirectory, PdfToImagesConfig? config}) {
    final result = PdfWorkerPlatform.instance.pdfToImages(inputPath: inputPath, outputDirectory: outputDirectory, config: config?.toJson());
    return result;
  }

  // pdf to long image
  Future<String>pdfToLongImage({required String inputPath, required String outputPath, PdfToImagesConfig? config}) {
    return PdfWorkerPlatform.instance.pdfToLongImage(inputPath: inputPath, outputPath: outputPath, config: config?.toJson());
  }
}
