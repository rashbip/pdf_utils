# Page Numbering & Custom Headers

`pdf_utils` provides a flexible way to add page numbers, headers, and footers to your PDF documents.

## Dynamic Tags
- `{total}`: Total pages in the document.
- `{image}`: Inline image placeholder (requires `imagePath`).

## Placements
Supported values via **`PdfTextPlacement`** enum:
- `topLeft`, `topCenter`, `topRight`
- `bottomLeft`, `bottomCenter`, `bottomRight` (Default)

## Basic Usage
```dart
final numbered = await PdfUtils.addPageNumbers(
  filePath: '/path/to/doc.pdf',
  customText: 'Page {n} of {total}',
  fontSize: 10,
  placement: PdfTextPlacement.bottomRight,
);
```

## Inline Images
You can insert an image inside your text line. The image will be automatically scaled to match the `fontSize` while maintaining its aspect ratio.

```dart
final numbered = await PdfUtils.addPageNumbers(
  filePath: '/path/to/my_doc.pdf',
  customText: 'Report by {image} - Page {n}', 
  imagePath: '/path/to/logo.png',
  fontSize: 10,
  placement: PdfTextPlacement.topCenter,
);
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
