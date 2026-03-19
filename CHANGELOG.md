# 3.0.0
**Note**: 
* **Major Refactor: PDFBox Integration**: Tried Replacing ENgine with iText7 but it was working as expected, but the issue is license. It doesn't provide free license for commercial use, so Migrated the core engine back to PDFBox (Apache 2.0 license) for full legal compliance and maximum efficiency . And exploring iText7 helped me to add many more fature out of pdfbox. I'm just trying to add features that are not offered by pdfbox directly. 
* **Breaking Change: Enhanced API Structure**: Unified and streamlined the `PdfUtils` API with cleaner models (`PdfValidity`, `PdfPageSize`) and more consistent method naming across Dart and Native.

**New Features:** 
* **New Feature: Smart PDF Compression**: Significantly reduce PDF file size by removing structural bloat and optimizing images natively via PDFBox.
* **New Feature: Native PDF Watermarking**: Professional text watermarking with customizable transparency, rotation, and colors.
* **New Feature: PDF Security Analysis**: Retrieve detailed security permissions and validity via `getValidity`.
* **New Feature: Detailed Page Metrics**: Discover architectural dimensions (width/height) for every page via `getPagesSize`.
* **Optimized Page Manipulation**: Reorder, delete, and rotate pages in a single high-speed native pass via `manipulatePages`.
* **Improved Performance**: Lightning-fast native image-to-PDF and merging implementations using optimized PDFBox-android APIs.
* **Project Structure**: Cleaned up the Android source into modular helper classes for better maintainability and professional codebase.
* **Documentation**: Split documentation into feature-specific files in the `doc` folder.

**Imroved Features:** 
* **Improved PDF Compression**: Reduced PDF file size by removing structural bloat and optimizing images natively via PDFBox.
* **Improved PDF Watermarking**: Professional text watermarking with customizable transparency, rotation, and colors.
* **Improved PDF Security Analysis**: Retrieve detailed security permissions and validity via `getValidity`.
* **Improved PDF Page Metrics**: Discover architectural dimensions (width/height) for every page via `getPagesSize`.
* **Improved Page Manipulation**: Reorder, delete, and rotate pages in a single high-speed native pass via `manipulatePages`.
* **Improved Performance**: Lightning-fast native image-to-PDF and merging implementations using optimized PDFBox-android APIs.
* **Improved Project Structure**: Cleaned up the Android source into modular helper classes for better maintainability and professional codebase.
* **Improved Documentation**: Split documentation into feature-specific files in the `doc` folder.

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
