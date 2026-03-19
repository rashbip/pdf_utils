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

## PDF Compression
Reduce PDF file size by optimizing images and removing embedded fonts.

```dart
final compressed = await PdfUtils.compressPdf(
  filePath: '/path/to/my_doc.pdf',
  quality: 50, // Image quality (0-100)
  scale: 0.7, // Image scaling factor (0.0-1.0)
  unEmbedFonts: true, // Remove embedded fonts to save space
);
```

## PDF Watermarking
Add professional text watermarks to your documents.

```dart
final watermarked = await PdfUtils.watermarkPdf(
  filePath: '/path/to/my_doc.pdf',
  text: 'CONFIDENTIAL',
  fontSize: 60.0,
  opacity: 0.2, // Watermark opacity (0.0-1.0)
  rotation: 45.0, // Rotation angle in degrees
  color: '#FF0000', // Hex color string
  position: 'Center', // Position: Center, TopLeft, etc.
);
```

## PDF Splitting
Divide a PDF into multiple documents by page count or specific page numbers.

```dart
// Split every 2 pages
final files = await PdfUtils.splitPdfByPageCount(
  filePath: '/path/to/my_doc.pdf',
  pageCount: 2,
);

// Split at specific page numbers
final filesAtIndices = await PdfUtils.splitPdfByPageNumbers(
  filePath: '/path/to/my_doc.pdf',
  pageNumbers: [5, 10], // Split after page 5 and page 10
);
```

## Page Manipulation
Reorder, delete, or rotate specific pages within a PDF.

```dart
final modified = await PdfUtils.manipulatePages(
  filePath: '/path/to/my_doc.pdf',
  reorder: [3, 1, 2], // New order of pages (1-indexed)
  delete: [4], // Remove page 4
  rotate: {1: 90, 2: 180}, // Rotate page 1 by 90 deg and page 2 by 180 deg
);
```
