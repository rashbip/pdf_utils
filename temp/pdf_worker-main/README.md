# pdf_worker

A new Flutter plugin project. you can lock, unlock PDF file.

## Getting Started

### usage

```dart
final pdfWorker = PdfWorker();

try {
    // path need the device pdf file path
    final isEncrypted = await pdfWorker.isEncrypted(filePath: 'test.pdf');
    await pdfWorker.lock(filePath: 'test.pdf', password: '123456');
    final locked = await pdfWorker.unlock(filePath: 'test.pdf', password: '123456');

    // replace your file path, or look example
    final outputPath = await pdfWorker.choosePagesIndexToMerge(
      inputPath: 'test.pdf',
      outputPath: 'outpath.pdf',
      pagesIndex: [1, 2],
    );
    final mergedPath = await pdfWorker.mergePdfFiles(
      filesPath: ['test.pdf', 'test1.pdf'],
      outputPath: 'outpath.pdf',
    );


    final longImagePath = await pdfWorker.pdfToLongImage(
      inputPath: 'test.pdf',
      outputPath: 'outpath.jpg',
      pagesIndex: [1, 2],
    );


    final imagesPath = await pdfWorker.pdfToImages(
      inputPath: 'test.pdf',
      outputDirectory: 'outpath',
      config: PdfToImagesConfig(
        pagesIndex: [1, 2],
        imgFormat: ImageFormat.jpg,
        quality: 80,
      ),
    );
} catch (e) {
    debugPrint(e.toString());
}

```

### TODO List

- [x] add merge pdf to long picture
- [x] add images to pdf 
- [x] add pdf to images



