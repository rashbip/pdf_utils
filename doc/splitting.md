# Merging & Splitting
`pdf_utils` provides native high-performance merging and splitting methods.

## Merging PDFs
![Merge PDFs](screenshots/merge.png)
*Figure: High-speed native merging of multiple PDF documents.*

## Splitting PDFs
![Split PDFs](screenshots/split.png)
*Figure: Splitting a PDF by fixed page count or specific page numbers.*
Splitting PDF files into multiple smaller documents is simple with `pdf_utils`.

## Split by Page Count
Break a document into files of a specific page size.

```dart
import 'package:pdf_utils/pdf_utils.dart';

void splitByCount() async {
  // Split every 2 pages into new documents
  final files = await PdfUtils.splitPdfByPageCount(
    filePath: '/path/to/my_doc.pdf',
    pageCount: 2,
  );
  
  if (files.isNotEmpty) {
    print('Split complete. Obtained ${files.length} files.');
  }
}
```

## Split at specific page indices
Split a document at given page numbers to divide it at specific points.

```dart
void splitAtIndices() async {
  // Split at pages 5 and 10 to create 3 segments
  final filesAtIndices = await PdfUtils.splitPdfByPageNumbers(
    filePath: '/path/to/my_doc.pdf',
    pageNumbers: [5, 10], 
  );
}
```
