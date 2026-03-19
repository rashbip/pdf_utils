import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class PdfToImageScreen extends StatefulWidget {
  const PdfToImageScreen({super.key});

  @override
  State<PdfToImageScreen> createState() => _PdfToImageScreenState();
}

class _PdfToImageScreenState extends State<PdfToImageScreen> {
  String? _statusMessage;
  List<String> _extractedImages = [];

  Future<void> _extractPdfToImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    final pdfPath = result.files.single.path!;
    final appDir = await getApplicationDocumentsDirectory();
    final outputDir = '${appDir.path}/extracted_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _statusMessage = 'Extracting pages from PDF...';
      _extractedImages = [];
    });
    try {
      final imagePaths = await PdfUtils.pdfToImages(
        pdfPath: pdfPath,
        outputDirectory: outputDir,
        onProgress: (current, total) {
          setState(() {
            _statusMessage = 'Extracting: $current / $total';
          });
        },
      );

      setState(() {
        _statusMessage = 'Extracted ${imagePaths.length} images to $outputDir';
        _extractedImages = imagePaths;
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  Future<void> _convertToLongImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _statusMessage = 'Generating long image...';
      _extractedImages = [];
    });
    try {
      final file = await PdfUtils.pdfToLongImage(
        pdfPath: result.files.single.path!,
        outputFileName: 'long_image_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _statusMessage = 'Long image created: ${file.path}';
        _extractedImages = [file.path];
      });
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF to Images')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Convert PDF pages into high-quality JPEG images or a single long vertical composite.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _extractPdfToImages,
                icon: const Icon(Icons.view_carousel),
                label: const Text('Extract Pages into Separate Images'),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _convertToLongImage,
                icon: const Icon(Icons.view_headline),
                label: const Text('Convert Entire PDF to Long Image'),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 20),
                Text(_statusMessage!, textAlign: TextAlign.center),
              ],
              if (_extractedImages.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Extracted Previews:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _extractedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => OpenFilex.open(_extractedImages[index]),
                            child: Image.file(
                              File(_extractedImages[index]),
                              fit: BoxFit.cover,
                              width: 140,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
