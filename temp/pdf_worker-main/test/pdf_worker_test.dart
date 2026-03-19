import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_worker/pdf_worker.dart';
import 'package:pdf_worker/pdf_worker_platform_interface.dart';
import 'package:pdf_worker/pdf_worker_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPdfWorkerPlatform
    with MockPlatformInterfaceMixin
    implements PdfWorkerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> isEncrypted({required String filePath}) => Future.value(false);

  @override
  Future<bool> isEncryptedByTail({required String filePath}) => Future.value(false);

  @override
  Future<bool> lock({required String filePath, required String userPassword, required String ownerPassword}) {
    return Future.value(false);
  }

  @override
  Future<bool> unlock({required String filePath, required String password}) {
    return Future.value(false);
  }

  @override
  Future<String?>choosePagesIndexToMerge({required String inputPath, required String outputPath, required List<int> pagesIndex}) {
    return Future.value(null);
  }

  @override
  Future<String>mergePdfFiles({required List<String> filesPath, required String outputPath}) {
    return Future.value('');
  }

  @override
  Future<String>mergeImagesToPdf({required List<String> imagesPath, required String outputPath, Map<String, dynamic>? config}) {
    return Future.value('');
  }

  @override
  Future<List<String>>pdfToImages({required String inputPath, required String outputDirectory, Map<String, dynamic>? config}) {
    return Future.value([]);
  }

  @override
  Future<String>pdfToLongImage({required String inputPath, required String outputPath, Map<String, dynamic>? config}) {
    return Future.value('');
  }
}

void main() {
  final PdfWorkerPlatform initialPlatform = PdfWorkerPlatform.instance;

  test('$MethodChannelPdfWorker is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPdfWorker>());
  });

  test('getPlatformVersion', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    expect(await pdfWorkerPlugin.getPlatformVersion(), '42');
  });

  test('isEncryptedByTail', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    expect(await pdfWorkerPlugin.isEncryptedByTail(filePath: 'test.pdf'), false);
  });

  test('isEncrypted', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    expect(await pdfWorkerPlugin.isEncrypted(filePath: 'test.pdf'), false);
  });

  test('lock', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    await pdfWorkerPlugin.lock(filePath: 'test.pdf', userPassword: '123456', ownerPassword: '123456');
  });

  test('unlock', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    expect(await pdfWorkerPlugin.unlock(filePath: 'test.pdf', password: '123456'), false);
  });

  test('choosePagesIndexToMerge', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    expect(await pdfWorkerPlugin.choosePagesIndexToMerge(inputPath: 'test.pdf', outputPath: 'test.pdf', pagesIndex: [1, 2, 3]), null);
  });

  test('mergePdfFiles', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    expect(await pdfWorkerPlugin.mergePdfFiles(filesPath: ['test.pdf'], outputPath: 'test.pdf'), '');
  });

  test('mergeImagesToPdf', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    expect(await pdfWorkerPlugin.mergeImagesToPdf(imagesPath: ['test.png'], outputPath: 'test.pdf'), '');
  });

  test('pdfToImages', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    expect(await pdfWorkerPlugin.pdfToImages(inputPath: 'test.pdf', outputDirectory: 'test'), []);
  });

  test('pdfToLongImage', () async {
    PdfWorker pdfWorkerPlugin = PdfWorker();
    MockPdfWorkerPlatform fakePlatform = MockPdfWorkerPlatform();
    PdfWorkerPlatform.instance = fakePlatform;

    expect(await pdfWorkerPlugin.pdfToLongImage(inputPath: 'test.pdf', outputPath: 'test.pdf', config: PdfToImagesConfig()), '');
  });
}
