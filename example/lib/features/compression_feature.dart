import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

class CompressionFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const CompressionFeature({super.key, required this.onStatusChange});

  @override
  State<CompressionFeature> createState() => _CompressionFeatureState();
}

class _CompressionFeatureState extends State<CompressionFeature> {
  Future<void> _compressPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Compressing PDF (Standard)...');
    try {
      final file = await PdfUtils.compressPdf(
        filePath: result.files.single.path!,
        quality: 50,
        scale: 0.7,
      );
      if (file != null) {
        widget.onStatusChange('PDF Compressed: ${file.path}');
        await OpenFilex.open(file.path);
      } else {
        widget.onStatusChange('Compression failed.');
      }
    } catch (e) {
      widget.onStatusChange('Error compressing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeatureCard(
      title: 'Compress PDF',
      description: 'Reduce file size by optimizing images.',
      icon: Icons.compress,
      onPressed: _compressPdf,
      color: Colors.brown.shade50,
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
              Icon(icon, size: 40, color: Colors.brown.shade700),
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
