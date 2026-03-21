# pdf_utils

A comprehensive, standalone Flutter plugin for professional PDF manipulation and generation. It has 28+ tools! Just using a single small library! 

[![pub package](https://img.shields.io/pub/v/pdf_utils.svg)](https://pub.dev/packages/pdf_utils)
[![Dart](https://img.shields.io/badge/language-Dart-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[**Pub.dev**](https://pub.dev/packages/pdf_utils) | [**Repository**](https://github.com/rashbip/pdf_utils) | [**Issues**](https://github.com/rashbip/pdf_utils/issues) | [**Documentation**](doc/invoice_generation.md)

---

- 1. Powerful PDF Compression!
- 2. Advanced PDF Viewer (`BipPdfViewer`)
- 3. Lightweight PDF Thumbnails
- 4. Page Manipulation 
  - i. Reorder,
  - ii. Delete,
  - iii. Rotate,
  - iv. Insert
- 5. Combine/Split PDFs
  - i. PDF Merging,
  - ii. PDF Splitting
- 6. PDF Resizing
  - i. Smart PDF Resizing(Actually!),
  - ii. Smart PDF Scaling
- 7. Extraction
  - i. Extract Text From PDF!
  - ii. Extract Metadata
  - iii. Extract Images From PDF!
- 8. Security Status
  - i. Check Security Status (locked/unlocked)
  - ii. Check Permissions(If editable/printable/copyable/annotatable etc.)
- 9. Encryption & Decryption
  - i. Lock PDF
  - ii. Unlock PDF
- 10. Overlay
  - i. Auto Page Numbering
  - ii. Customizable headers and footers
  - iii. Add Text Overlay
  - iv. Add Image Overlay
  - v. Add Text and Image at once!
  - vi. Add Text and Image as watermark!
- 11. Native System Printing
- 12. High-Speed Image to PDF Conversion
- 13. Auto Blank Page Removal!
- 14. Professional Invoice Generation!
- That means 28+ tools! And some small features!
- More Features Coming Soon!
## Showcase

### 🎨 Creation & Design
| Invoice Generation | Image to PDF | Advanced Watermark |
| :---: | :---: | :---: |
| ![Invoice Demo](doc/screenshots/invoice_generator.png) | ![App Home](doc/screenshots/image_to_pdf.png) | ![Watermarking](doc/screenshots/watermarking.png) |
| *Professional Invoices* | *Native Image-to-PDF* | *Advanced Branding* |

### 📄 Page Manipulation & Assembly
| Reorder & Delete | Insert Page/Image | Dynamic Numbering |
| :---: | :---: | :---: |
| ![Reorder/Delete](doc/screenshots/reorder.png) | ![Insert Page](doc/screenshots/insert.png) | ![Page Numbering](doc/screenshots/add_footer_header.png) |
| *Page Reorganization* | *Flexible Insertion* | *Headers & Footers* |

| Merge PDFs | Split PDFs | Page Resizing |
| :---: | :---: | :---: |
| ![Merge PDF](doc/screenshots/merge.png) | ![Split PDF](doc/screenshots/split.png) | ![Resize Page](doc/screenshots/resize_pages.png) |
| *Native High-Speed Merge* | *Selective Splitting* | *A4/Target Rescaling* |

### 🛠️ Utilities & Analysis
| Advanced Viewer | Lightweight Thumbnails | Security Status |
| :---: | :---: | :---: |
| ![PDF Viewer](doc/screenshots/pdf_viewer.png) | ![Thumbnails](doc/screenshots/get_thumbnails.png) | ![Security Status](doc/screenshots/check_security.png) |
| *Premium BipPdfViewer* | *Fast Page Previews* | *Permission Analysis* |

| Native Printing | PDF Compression | Image Extraction |
| :---: | :---: | :---: |
| ![Native Print](doc/screenshots/print.png) | ![Compression](doc/screenshots/compress.png) | ![Extraction](doc/screenshots/pdf_to_images.png) |
| *System Print Dialog* | *File Size Optimization* | *Page to Image* |

| Long Image | Text Extraction |
| :---: | :---: |
| ![Long Image](doc/screenshots/long_image.png) | ![Text Extraction](doc/screenshots/extract_text.png) |
| *Long Vertical Layouts* | *Robust Text Retrieval* |

## Installation

Add `pdf_utils` to your `pubspec.yaml`:

```yaml
dependencies:
  pdf_utils: ^3.3.0
```

## Quick Start

### 1. Generating an Invoice

```dart
final invoice = Invoice(...);
File pdfFile = await PdfInvoiceGenerator.generate(invoice);
```

### 2. Merging PDFs (Native)

```dart
File? merged = await PdfUtils.mergePdfs(
  ['path1.pdf', 'path2.pdf'],
);
```

### 3. Advanced Viewer

```dart
Navigator.push(
  context, 
  MaterialPageRoute(
    builder: (context) => BipPdfViewer(
      filePath: 'my_doc.pdf',
      title: 'Monthly Report',
    )
  )
);
```

### 4. Text & Metadata Extraction

```dart
final doc = await PDFDoc.fromPath('doc.pdf');
String text = await doc.text;
print('Total pages: ${doc.length}');
print('Author: ${doc.info.author}');
```

### 5. Locking a PDF

```dart
File? secured = await PdfUtils.encryptPdf(
  filePath: 'doc.pdf',
  userPassword: 'my_password',
  allowPrinting: true,
);
```

## Documentation

Full detailed guides are available in the **[doc/](doc/)** folder:
- **[Invoice Generation](doc/invoice_generation.md)**
- **[PDF Viewer](doc/viewer.md)**
- **[Lightweight Thumbnails](doc/thumbnails.md)**
- **[Page Manipulation](doc/manipulation.md)**
- **[Watermarking](doc/watermarking.md)**
- **[Page Numbering](doc/page_numbering.md)**
- **[PDF Resizing](doc/resizing.md)**
- **[Security & Protection](doc/security.md)**
- **[Text Extraction](doc/text_extraction.md)**
- **[Splitting & Merging](doc/splitting.md)**
- **[Compression](doc/compression.md)**
- **[Conversion & Extraction](doc/conversion.md)**

## Example App

Check the `example` folder for a complete demonstration of the plugin's features on real devices.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
