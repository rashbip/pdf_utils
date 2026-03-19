import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:file_picker/file_picker.dart';

class TextExtractionScreen extends StatefulWidget {
  const TextExtractionScreen({super.key});

  @override
  State<TextExtractionScreen> createState() => _TextExtractionScreenState();
}

class _TextExtractionScreenState extends State<TextExtractionScreen> {
  String? _statusMessage;

  Future<void> _extractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() => _statusMessage = 'Extracting text and metadata...');
    try {
      final doc = await PDFDoc.fromPath(result.files.single.path!);
      final text = await doc.text;
      final info = doc.info;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(info.title ?? 'PDF Info'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Author: ${info.author ?? 'Unknown'}'),
                Text('Pages: ${doc.length}'),
                Text('Creation Date: ${info.creationDate ?? 'Unknown'}'),
                const Divider(),
                const Text('Extracted Text (Snippet):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(text.length > 1000 ? '${text.substring(0, 1000)}...' : text),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      setState(() => _statusMessage = 'Text extraction complete.');
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text & Metadata Extraction')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Extract full text, specific pages, and important metadata from PDF documents.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _extractText,
              icon: const Icon(Icons.text_snippet),
              label: const Text('Select PDF & Extract Info'),
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
