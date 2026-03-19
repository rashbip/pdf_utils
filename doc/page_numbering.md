# Page Numbering & Custom Headers

`pdf_utils` provides a flexible way to add page numbers, headers, and footers to your PDF documents.

## Dynamic Tags
You can include special tags in your text that will be replaced during processing:
- `{n}`: Current page number (1-based).
- `{total}`: Total pages in the document.

## Placements
Supported quadrants for text placement:
- `TOP_LEFT`, `TOP_CENTER`, `TOP_RIGHT`
- `BOTTOM_LEFT`, `BOTTOM_CENTER`, `BOTTOM_RIGHT` (Default: `BOTTOM_CENTER`)

## Basic Usage
```dart
import 'package:pdf_utils/pdf_utils.dart';

void addNumbers() async {
  final numbered = await PdfUtils.addPageNumbers(
    filePath: '/path/to/my_doc.pdf',
    customText: 'Page {n} of {total}', // Tags will be replaced
    fontSize: 10,
    placement: 'BOTTOM_RIGHT',
  );
}
```

## Selective Numbering
Apply numbering to a specific range or individual pages only.

```dart
final partialNumbered = await PdfUtils.addPageNumbers(
  filePath: '/path/to/my_doc.pdf',
  customText: 'Report #1234',
  pages: [1, 2, 5], // Only pages 1, 2, and 5 will have the header
);
```

### Key Notes
- `fontSize` defaults to 12.
- Text is rendered using a standard Helvetica font for wide compatibility.
- Both `pages` and `{n}`/`{total}` use **1-indexed** counting. 
