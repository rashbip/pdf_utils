import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_worker/pdf_worker.dart';



class LockerController extends GetxController {
  final _pdfWorkerPlugin = PdfWorker();
  final platformVersion = 'unknown'.obs;
  late final String tempFilePath;
  @override
  void onInit() {
    super.onInit();
    _initPlatformState();
    _copyAssetToTemp(
      assetPath: 'assets/Swift PDF Example.pdf',
      tempName: 'swift_pdf_example.pdf',
    );
  }

  Future<void> _initPlatformState() async {
    final platformVersion =
        await _pdfWorkerPlugin.getPlatformVersion() ??
        'Unknown platform version';

    this.platformVersion.value = platformVersion;
  }

  //
  void _copyAssetToTemp({
    required String assetPath,
    required String tempName,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$tempName')
      ..createSync(recursive: true)
      ..writeAsBytesSync(byteData.buffer.asUint8List());
    tempFilePath = file.path;
  }

  Future<void> checkIfPdfIsEncryptedByTail() async {
    try {
      final result = await _pdfWorkerPlugin.isEncryptedByTail(filePath: tempFilePath);
      Get.snackbar('Is Encrypted By Tail', result ? 'Yes' : 'No');
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> checkIfPdfIsEncrypted() async {
    try {
      final result = await _pdfWorkerPlugin.isEncrypted(filePath: tempFilePath);
      Get.snackbar('Is Encrypted', result ? 'Yes' : 'No');
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> lockPdf() async {
    try {
      await _pdfWorkerPlugin.lock(
        filePath: tempFilePath,
        userPassword: '123456',
        ownerPassword: '',
      );
      Get.snackbar('Lock PDF', 'Success');
    } catch (e) {
      Get.snackbar('Lock PDF', 'Failed');
    }
  }

  Future<void> unlockPdf() async {
    try {
      final result = await _pdfWorkerPlugin.unlock(
        filePath: tempFilePath,
        password: '123456',
      );
      Get.snackbar('Unlock PDF', result ? 'Success' : 'Failed');
    } catch (e) {
      Get.snackbar('Unlock PDF', 'Failed');
    }
  }
}

class LockerPage extends GetView<LockerController> {
  const LockerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Locker Page')),
      body: Center(
        child: Column(
          spacing: 24,
          children: [
            Obx(
              () =>
                  Text('Platform Version: ${controller.platformVersion.value}'),
            ),

            ElevatedButton(
              onPressed: () {
                controller.checkIfPdfIsEncryptedByTail();
              },
              child: const Text('Check If PDF Is Encrypted By Tail'),
            ),

            ElevatedButton(
              onPressed: () {
                controller.checkIfPdfIsEncrypted();
              },
              child: const Text('Check If PDF Is Encrypted'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.lockPdf();
              },
              child: const Text('Lock PDF'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.unlockPdf();
              },
              child: const Text('Unlock PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
