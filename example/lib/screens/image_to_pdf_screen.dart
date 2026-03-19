import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:image_picker/image_picker.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  String? _statusMessage;

  Future<void> _convertImagesToPdf() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isEmpty) return;

    setState(() => _statusMessage = 'Converting ${images.length} images to PDF (Native)...');
    try {
      final file = await PdfUtils.nativeImagesToPdf(
        imagePaths: images.map((e) => e.path).toList(),
        outputFileName: 'converted_images_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _statusMessage = 'PDF created: ${file.path}';
      });
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Images to PDF')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Select multiple images to combine into a single, multipage PDF document using native optimization.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _convertImagesToPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Select Images & Convert'),
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
