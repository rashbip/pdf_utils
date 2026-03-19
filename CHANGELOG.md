# 2.2.0

* **New Feature: PDF Compression**: Added capability to reduce PDF file size by optimizing images and removing fonts via `PdfUtils.compressPdf`.
* **New Feature: PDF Watermarking**: Added professional text watermarking support with customizable rotation, opacity, and positioning via `PdfUtils.watermarkPdf`.
* **New Feature: PDF Splitting**: Divide PDFs by page count or specific page numbers via `PdfUtils.splitPdfByPageCount` and `PdfUtils.splitPdfByPageNumbers`.
* **New Feature: Page Manipulation**: Reorder, delete, and rotate specific pages via `PdfUtils.manipulatePages`.
* **Native Enhancements**: Integrated iText7 for advanced PDF operations on Android.

# 2.1.0

* **Improved Example App**: Refactored to feature-based structure for better readability.
* **Remove PDF Password**: Added support and example for removing (unlocking) PDF passwords.
* **Android/Gradle Upgrades**: Upgraded Gradle and internal dependencies for better compatibility.
* **Flutter Optimizations**: Updated dependencies and improved method channel handling.

# 2.0.0

* **Standalone Implementation**: Removed external dependencies (`pdf_worker` and `flutter_pdf_text`).
* **Native PDF Processing**: Integrated PDFBox (Android) and PDFKit (iOS) natively for faster and more reliable processing.
* **New Features**:
    * PDF Protection (Lock/Unlock) with password.
    * PDF Merging (Combine multiple PDFs).
    * Choose specific pages from a PDF to merge.
    * High-performance Native PDF to Image conversion.
    * PDF to Long Image conversion.
    * Full Text extraction, metadata retrieval, and page count.
* **Bug Fixes**: Fixed several minor issues in text extraction and page rendering.

# 1.0.0

* Initial release.
* Professional invoice generation with customizable models.
* Image to PDF conversion.
* PDF to Image extraction with progress tracking.
* Full DartDoc documentation.
* Example application.
