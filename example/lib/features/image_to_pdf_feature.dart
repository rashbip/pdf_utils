import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:image_picker/image_picker.dart';

class ImageToPdfFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const ImageToPdfFeature({super.key, required this.onStatusChange});

  @override
  State<ImageToPdfFeature> createState() => _ImageToPdfFeatureState();
}

class _ImageToPdfFeatureState extends State<ImageToPdfFeature> {
  Future<void> _convertImagesToPdf() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isEmpty) return;

    widget.onStatusChange('Converting ${images.length} images to PDF (Native)...');
    try {
      final files = await PdfUtils.imagesToPdfs(
        imagesPath: images.map((e) => e.path).toList(),
        createSinglePdf: true,
      );
      if (files.isNotEmpty) {
        widget.onStatusChange('PDF created: ${files.first.path}');
        await OpenFilex.open(files.first.path);
      }
    } catch (e) {
      widget.onStatusChange('Error converting images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeatureCard(
      title: 'Images to PDF',
      description: 'Select images & combine into a single PDF.',
      icon: Icons.picture_as_pdf,
      onPressed: _convertImagesToPdf,
      color: Colors.green.shade50,
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
              Icon(icon, size: 40, color: Colors.green.shade700),
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
