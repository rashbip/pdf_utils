# PDF Resizing

The resizing feature in `pdf_utils` allows you to scale PDF pages to match specific target dimensions while preserving the content's integrity.

## Smart Resizing
When you resize a page, `pdf_utils` ensures that:
1. **Aspect Ratio is Maintained**: The original content is scaled uniformly to fit within the new dimensions without distortion.
2. **Centering**: The scaled content is automatically centered within the new canvas.
3. **White Background**: Any remaining space on the target page (if ratios don't match) is filled with a clean white background.

## Basic Usage
```dart
import 'package:pdf_utils/pdf_utils.dart';

void resizeToA4() async {
  final resized = await PdfUtils.resizePdf(
    filePath: '/path/to/my_doc.pdf',
    width: 595,  // A4 Standard Width in points
    height: 842, // A4 Standard Height in points
  );
  
  if (resized != null) {
    print('A4 PDF saved at: ${resized.path}');
  }
}
```

## Selective Page Resizing
You can choose to resize only specific pages while keeping others at their original size.

```dart
// Resize only the first two pages to 600x600 square
final partialResize = await PdfUtils.resizePdf(
  filePath: '/path/to/my_doc.pdf',
  width: 600,
  height: 600,
  pages: [1, 2], // 1-indexed page list
);
```

### Key Notes
- `width` and `height` are measured in PDF points (1/72 inch). 
- `pages` is a **1-indexed** list for ease of mapping to user-visible page numbers. 
- Ideal for standardizing document sizes (e.g., ensuring all scanned pages fit an A4 canvas).
