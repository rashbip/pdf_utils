# Page Manipulation

Page manipulation in `pdf_utils` allows you to reorganize a PDF document efficiently.

## Reorder, Delete, and Rotate
![Page Reordering](screenshots/reorder.png)
*Figure: Interface for page reordering, deletion, and rotation.*

You can perform complex reorganizations in a single call.

```dart
import 'package:pdf_utils/pdf_utils.dart';

void manipulate() async {
  final modified = await PdfUtils.manipulatePages(
    filePath: '/path/to/my_doc.pdf',
    reorder: [3, 1, 2], // New sequence for existing pages (1-indexed)
    delete: [4],        // Remove page 4 from the final result
    rotate: {
      1: 90,           // Rotate the first page clockwise by 90°
      2: 180           // Rotate the second page by 180°
    },
  );
  
  if (modified != null) {
    print('Modified PDF saved at: ${modified.path}');
  }
}
```

### Key Notes
- `reorder`, `delete`, and `rotate` list indices are all **1-indexed** to match standard PDF page identification.
- Any page not in the `reorder` list but also not in the `delete` list won't be in the final document.

## Page Insertion
![Page Insertion](screenshots/insert.png)
*Figure: Feature to insert images and other PDF documents into a PDF file.*

`pdf_utils` allows you to insert new pages (from images or other PDFs) into an existing document with flexible positioning.

```dart
// Insert an image after the second page
final inserted = await PdfUtils.addPage(
  filePath: '/path/to/source.pdf',
  insertPath: '/path/to/image.jpg',
  afterPage: 2, 
);

// Insert a PDF before the first page
final prefixed = await PdfUtils.addPage(
  filePath: '/path/to/source.pdf',
  insertPath: '/path/to/other.pdf',
  beforePage: 1, 
);

// Insert directly at a 0-based index
final indexed = await PdfUtils.addPage(
  filePath: '/path/to/source.pdf',
  insertPath: '/path/to/other.pdf',
  index: 3, 
);
```

## Smart Blank Page Removal
Remove effectively empty pages from a PDF. A page is considered blank if it contains **no text** and **no graphics/images**.

```dart
final cleaned = await PdfUtils.removeBlankPages(
  filePath: '/path/to/messy_doc.pdf',
);
```

## Native PDF Printing
![PDF Printing](screenshots/print.png)
*Figure: Native system print dialog launched from the app.*

Launch the system's standard print dialog. Supports virtual printing (Save as PDF) and physical printers.

```dart
await PdfUtils.printPdf(
  filePath: '/path/to/my_doc.pdf',
  jobName: 'Print Job #1234', // Optional name for the print queue
);
```
