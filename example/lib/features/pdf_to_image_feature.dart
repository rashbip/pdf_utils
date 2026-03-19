import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class PdfToImageFeature extends StatefulWidget {
  final Function(String, {List<String>? previews}) onProgress;
  const PdfToImageFeature({super.key, required this.onProgress});

  @override
  State<PdfToImageFeature> createState() => _PdfToImageFeatureState();
}

class _PdfToImageFeatureState extends State<PdfToImageFeature> {
  Future<void> _extractPdfToImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    final pdfPath = result.files.single.path!;
    final appDir = await getApplicationDocumentsDirectory();
    final outputDir = '${appDir.path}/extracted_${DateTime.now().millisecondsSinceEpoch}';

    widget.onProgress('Extracting pages...', previews: []);
    try {
      final imagePaths = await PdfUtils.pdfToImages(
        pdfPath: pdfPath,
        outputDirectory: outputDir,
      );
      widget.onProgress('Extracted ${imagePaths.length} images to $outputDir', previews: imagePaths);
    } catch (e) {
      widget.onProgress('Error extracting images: $e');
    }
  }

  Future<void> _convertToLongImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onProgress('Generating long image...', previews: []);
    try {
      final appDir = await getTemporaryDirectory();
      final outputPath = '${appDir.path}/long_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await PdfUtils.pdfToLongImage(
        pdfPath: result.files.single.path!,
        outputPath: outputPath,
      );
      if (file != null) {
        widget.onProgress('Long image created: ${file.path}', previews: [file.path]);
      }
    } catch (e) {
      widget.onProgress('Error generating long image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(
          title: 'PDF to Images',
          description: 'Extract pages as separate JPEG images.',
          icon: Icons.view_carousel,
          onPressed: _extractPdfToImages,
          color: Colors.orange.shade50,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'PDF to Long Image',
          description: 'Combine all pages into one tall image.',
          icon: Icons.view_headline,
          onPressed: _convertToLongImage,
          color: Colors.yellow.shade50,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: color,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.orange.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
