# PDF Conversion

Converting images to PDFs and extracting pages as images are two of the most common high-performance operations in `pdf_utils`.

## Image to PDF
Combine multiple images into one or more PDF documents.

### Native Conversion (Optimized)
Native conversion using the iText7 engine is extremely fast.

```dart
import 'package:pdf_utils/pdf_utils.dart';

void convertImages() async {
  final images = ['/path/to/image1.jpg', '/path/to/image2.png'];
  
  // Create one single PDF from all images
  final files = await PdfUtils.imagesToPdfs(
    imagesPath: images,
    createSinglePdf: true,
  );
  
  if (files.isNotEmpty) {
    print('Generated PDF at: ${files.first.path}');
  }
}
```

## PDF to Images
Extract pages from a PDF document as high-quality JPEG images.

### Standard Extraction
Extract pages individually into an output directory.

```dart
import 'package:pdf_utils/pdf_utils.dart';

void extractImages() async {
  final imagePaths = await PdfUtils.pdfToImages(
    pdfPath: '/path/to/my_doc.pdf',
    outputDirectory: '/output/path',
  );
  
  if (imagePaths.isNotEmpty) {
    print('Extracted ${imagePaths.length} images.');
  }
}
```

### Long Image Extraction
Combine all pages into one single long vertical image.

```dart
void longImage() async {
  final longImage = await PdfUtils.pdfToLongImage(
    pdfPath: '/path/to/my_doc.pdf',
    outputPath: '/output/path/final_long_image.jpg',
  );
  
  if (longImage != null) {
    print('Long image saved at: ${longImage.path}');
  }
}
```
