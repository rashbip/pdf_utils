# PDF Manipulation

The `pdf_utils` plugin provides simple static methods for converting images to PDF and vice-versa.

## Image to PDF

Use `PdfUtils.imagesToPdf` to combine multiple images into a single PDF document.

### Example

```dart
import 'package:pdf_utils/pdf_utils.dart';

void convertImages() async {
  final images = [
    '/path/to/image1.jpg',
    '/path/to/image2.png',
  ];

  final pdfFile = await PdfUtils.imagesToPdf(
    imagePaths: images,
    outputFileName: 'my_collection',
  );

  print('PDF created at: ${pdfFile.path}');
}
```

## PDF to Images

Use `PdfUtils.pdfToImages` to extract pages from a PDF document as high-quality JPEG images.

### Example

```dart
import 'package:pdf_utils/pdf_utils.dart';

void extractPages() async {
  final outputDir = Directory('/path/to/extracted/images');
  
  final images = await PdfUtils.pdfToImages(
    pdfPath: '/path/to/my_doc.pdf',
    outputDirectory: outputDir.path,
    onProgress: (current, total) {
      print('Processing page $current of $total');
    },
  );

  print('Extracted ${images.length} images.');
}
```

### Options

- **Quality**: The extractor uses a 2x scale by default for better quality (hardcoded in the current version).
- **Progress tracking**: The optional `onProgress` callback allows you to update your UI (e.g., showing a progress bar) during the extraction process.
