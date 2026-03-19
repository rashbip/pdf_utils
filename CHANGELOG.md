# 3.0.0

* **Major Refactor: iText7 Integration**: Completely replaced underlying technology with the powerful iText7 engine for all major PDF operations (Android only).
* **Breaking Change: New API Structure**: Streamlined the `PdfUtils` API with better model support (`PdfValidity`, `PdfPageSize`) and more consistent method naming.
* **New Feature: PDF Security Analysis**: Retrieve comprehensive information about PDF validity and detailed security permissions via `PdfUtils.getValidity`.
* **New Feature: Advanced Encryption**: Fine-tune security permissions including printing, copying, and modification flags via `PdfUtils.encryptPdf`.
* **New Feature: Page Size Discovery**: Get architectural dimensions for every page in your PDF via `PdfUtils.getPagesSize`.
* **New Feature: PDF Splitting (Advanced)**: New high-performance splitting methods for broken-up documents.
* **Improved Page Manipulation**: Reorder, delete, and rotate pages in a single optimized pass via `PdfUtils.manipulatePages`.
* **Native Image to PDF**: Native iText7 implementation for lightning-fast image conversion.
* **Project Cleanup**: Removed redundant components for a smaller and more efficient plugin footprint.
* **Documentation**: Split documentation into feature-specific files in the `doc` folder.

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
