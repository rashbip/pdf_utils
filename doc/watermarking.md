# PDF Watermarking

The `pdf_utils` plugin provides highly customizable text watermarking using the iText7 library.

## Native Watermarking
Apply clear, professional text watermarks over or under existing page content.

```dart
import 'package:pdf_utils/pdf_utils.dart';

void watermark() async {
  final watermarked = await PdfUtils.watermarkPdf(
    filePath: '/path/to/my_doc.pdf',
    text: 'CONFIDENTIAL',
    fontSize: 60.0,
    opacity: 0.2, // Text transparency (0.0-1.0)
    rotation: 45.0, // Angle in degrees
    color: '#FF0000', // Hex color string
    position: 'Center', // See position options below
    layer: 'OverContent', // 'OverContent' or 'UnderContent'
  );
  
  if (watermarked != null) {
    print('Watermarked PDF saved at: ${watermarked.path}');
  }
}
```

### Positioning
Available positions:
- `Center` (default)
- `TopLeft`, `TopCenter`, `TopRight`
- `CenterLeft`, `CenterRight`
- `BottomLeft`, `BottomCenter`, `BottomRight`
- `Custom`: Set custom X and Y coordinates on the native side.
