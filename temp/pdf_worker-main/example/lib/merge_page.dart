import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_worker/pdf_worker.dart';
import 'package:pdfrx/pdfrx.dart';

class MergeController extends GetxController {
  final _pdfWorkerPlugin = PdfWorker();
  Rx<PdfDocumentRef?> docRef = Rx(null);
  late final String assetsPdfFilePath;
  @override
  void onInit() {
    super.onInit();

    _copyAssetToTemp(
      assetPath: 'assets/Swift PDF Example.pdf',
      tempName: 'swift_pdf_example.pdf',
    );
  }

  void _copyAssetToTemp({
    required String assetPath,
    required String tempName,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$tempName')
      ..createSync(recursive: true)
      ..writeAsBytesSync(byteData.buffer.asUint8List());
    assetsPdfFilePath = file.path;
  }

  Future<void> choosePagesToMerge() async {
    Get.showOverlay(
      asyncFunction: () async {
        try {
          final inputPath = assetsPdfFilePath;
          final pagesIndex = [1, 2];
          final tempDir = await getTemporaryDirectory();
          final outputPath = '${tempDir.path}/merged.pdf';
          final result = await _pdfWorkerPlugin.choosePagesIndexToMerge(
            inputPath: inputPath,
            outputPath: outputPath,
            pagesIndex: pagesIndex,
          );
          if (result != null) {
            docRef.value = PdfDocumentRefFile(result);
          }
        } catch (e) {
          Get.snackbar('Error', e.toString());
        }
      },
      loadingWidget: const CircularProgressIndicator(),
    );
  }

  Future<void> mergePdfFiles() async {
    Get.showOverlay(
      asyncFunction: () async {
        try {
          final tempDir = await getTemporaryDirectory();
          final mergedPath = '${tempDir.path}/merged.pdf'; // 1,2
          final outputPath = '${tempDir.path}/files_merged.pdf';
          final filesPath = [assetsPdfFilePath, mergedPath];
          final result = await _pdfWorkerPlugin.mergePdfFiles(
            filesPath: filesPath,
            outputPath: outputPath,
          );

          docRef.value = PdfDocumentRefFile(result);
        } catch (e) {
          Get.snackbar('Error', e.toString());
        }
      },
      loadingWidget: const CircularProgressIndicator(),
    );
  }

  Future<void> mergeImagesToPdf() async {
    Get.showOverlay(
      asyncFunction: () async {
        try {
          // pick images
          final imagesPath = await ImagePicker().pickMultiImage();
          if (imagesPath.isEmpty) return;

          final tempDir = await getTemporaryDirectory();
          final outputPath = '${tempDir.path}/images_merged.pdf';
          final filesPath = imagesPath.map((x) => x.path).toList();
          final result = await _pdfWorkerPlugin.mergeImagesToPdf(
            imagesPath: filesPath,
            outputPath: outputPath,
          );

          docRef.value = PdfDocumentRefFile(result);
        } catch (e) {
          Get.snackbar('Error', e.toString());
        }
      },
      loadingWidget: const CircularProgressIndicator(),
    );
  }

  Future<void> pdfToImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputDirectory = '${tempDir.path}/images';
      // create directory
      if (!Directory(outputDirectory).existsSync()) {
        Directory(outputDirectory).createSync(recursive: true);
      }

      FilePickerResult? pickResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      final inputPath = pickResult?.files.single.path;
      if (inputPath == null) return;
      final result = await Get.showOverlay(
        asyncFunction: () async {
          final result = await _pdfWorkerPlugin.pdfToImages(
            inputPath: inputPath,
            outputDirectory: outputDirectory,
            config: PdfToImagesConfig(
              // pagesIndex: [0, 3],
              imgFormat: ImageFormat.png,
              // quality: 30,
            ),
          );
          return result;
        },
        loadingWidget: const CircularProgressIndicator(),
      );

      Get.toNamed('/result', arguments: result);

      // show images
      // Get.snackbar('Success', 'PDF to images success ${result.length} images');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> pdfToLongImage() async {
    Get.showOverlay(
      asyncFunction: () async {
        try {
          final tempDir = await getTemporaryDirectory();
          final outputPath = '${tempDir.path}/long_image.jpg';
          final result = await _pdfWorkerPlugin.pdfToLongImage(
            inputPath: assetsPdfFilePath,
            outputPath: outputPath,
            config: PdfToImagesConfig(
              pagesIndex: [3, 2, 1, 0],
              imgFormat: ImageFormat.png,
              quality: 80,
            ),
          );
          Get.toNamed('/result', arguments: [result]);
          return result;
        } catch (e) {
          Get.snackbar('Error', e.toString());
        }
      },
      loadingWidget: const CircularProgressIndicator(),
    );
  }
}

class MergePage extends GetView<MergeController> {
  const MergePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merge Page')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              controller.choosePagesToMerge();
            },
            child: const Text('Choose Pages To Merge'),
          ),

          ElevatedButton(
            onPressed: () async {
              controller.mergePdfFiles();
            },
            child: const Text('Merge PDF Files'),
          ),

          // merge images to pdf
          ElevatedButton(
            onPressed: () async {
              controller.mergeImagesToPdf();
            },
            child: const Text('Merge Images To PDF '),
          ),

          // pdf to images
          ElevatedButton(
            onPressed: () async {
              controller.pdfToImages();
            },
            child: const Text('PDF To Images'),
          ),

          // pdf to long image
          ElevatedButton(
            onPressed: () async {
              controller.pdfToLongImage();
            },
            child: const Text('PDF To Long Image'),
          ),
          Obx(
            () => Expanded(
              child: controller.docRef.value != null
                  ? PdfViewer(controller.docRef.value!)
                  : const Center(child: Text('No PDF')),
            ),
          ),
        ],
      ),
    );
  }
}
