# PDF Manipulation

The `pdf_utils` plugin provides comprehensive static methods for converting, extracting, protecting, and merging PDF documents.

## Image to PDF

### Standard (pdf package)
Use `PdfUtils.imagesToPdf` to combine multiple images into a single PDF document using the high-level `pdf` package.

```dart
import 'package:pdf_utils/pdf_utils.dart';

void convertImages() async {
  final images = ['/path/to/image1.jpg', '/path/to/image2.png'];
  final pdfFile = await PdfUtils.imagesToPdf(
    imagePaths: images,
    outputFileName: 'my_collection',
  );
  print('PDF created at: ${pdfFile.path}');
}
```

### Native (Optimized)
Use `PdfUtils.nativeImagesToPdf` for a faster, natively optimized conversion with resizing options.

```dart
final pdfFile = await PdfUtils.nativeImagesToPdf(
  imagePaths: images,
  outputFileName: 'my_collection_native',
  maxWidth: 1024,
  maxHeight: 1024,
  keepAspectRatio: true,
);
```

## PDF to Images

### Standard Extraction
Use `PdfUtils.pdfToImages` to extract pages from a PDF document as separate image files.

```dart
final images = await PdfUtils.pdfToImages(
  pdfPath: '/path/to/my_doc.pdf',
  outputDirectory: '/output/path',
  onProgress: (current, total) => print('Processing $current/$total'),
);
```

### Long Image Extraction
Use `PdfUtils.pdfToLongImage` to convert a multi-page PDF into a single long vertical image.

```dart
final longImage = await PdfUtils.pdfToLongImage(
  pdfPath: '/path/to/my_doc.pdf',
  outputFileName: 'full_document_image',
);
```

## PDF Protection & Merging

### Locking & Unlocking
Secure your PDF files with password protection.

```dart
// Lock a PDF
final locked = await PdfUtils.protectPdf(
  inputPath: '/path/to/doc.pdf',
  password: 'my-secret-password',
  outputFileName: 'protected_doc',
);

// Unlock a PDF
final unlocked = await PdfUtils.unlockPdf(
  inputPath: locked.path,
  password: 'my-secret-password',
  outputFileName: 'unlocked_doc',
);

// Check if encrypted
bool isEncrypted = await PdfUtils.isEncrypted('/path/to/doc.pdf');
```

### Merging PDFs
Combine multiple PDF files or select specific pages to merge.

```dart
// Merge multiple files
final merged = await PdfUtils.mergePdfFiles(
  filesPath: ['/path/to/doc1.pdf', '/path/to/doc2.pdf'],
  outputFileName: 'combined_document',
);

// Merge specific pages from a single file
final selectedPages = await PdfUtils.choosePagesIndexToMerge(
  inputPath: '/path/to/doc.pdf',
  pagesIndex: [0, 2, 5], // 0-indexed
  outputFileName: 'extracted_pages',
);
```
