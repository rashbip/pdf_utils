import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

class MergePdfScreen extends StatefulWidget {
  const MergePdfScreen({super.key});

  @override
  State<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends State<MergePdfScreen> {
  String? _statusMessage;

  Future<void> _mergePdfs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return;

    final paths = result.files.map((e) => e.path!).toList();
    setState(() => _statusMessage = 'Merging ${paths.length} PDFs...');
    try {
      final file = await PdfUtils.mergePdfFiles(
        filesPath: paths,
        outputFileName: 'merged_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _statusMessage = 'Merged PDF created: ${file.path}';
      });
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  Future<void> _extractAndMerge() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() => _statusMessage = 'Extracting first 2 pages and merging them to a new PDF...');
    try {
      final file = await PdfUtils.choosePagesIndexToMerge(
        inputPath: result.files.single.path!,
        pagesIndex: [0, 1], // 0-indexed
        outputFileName: 'extracted_pages_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _statusMessage = 'Processed PDF created: ${file.path}';
      });
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merge & Split PDFs')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Combine multiple PDF documents or select specific pages to extract and merge.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _mergePdfs,
              icon: const Icon(Icons.merge_type),
              label: const Text('Select Multiple PDFs to Merge'),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _extractAndMerge,
              icon: const Icon(Icons.call_split),
              label: const Text('Extract and Merge Pages (0-1)'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 20),
              Text(_statusMessage!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
