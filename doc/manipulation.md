# Page Manipulation

Page manipulation in `pdf_utils` allows you to reorganize a PDF document efficiently.

## Reorder, Delete, and Rotate
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
