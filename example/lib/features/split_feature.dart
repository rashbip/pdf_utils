import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class SplitFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const SplitFeature({super.key, required this.onStatusChange});

  @override
  State<SplitFeature> createState() => _SplitFeatureState();
}

class _SplitFeatureState extends State<SplitFeature> {
  Future<void> _splitPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Splitting PDF (Each page as a file)...');
    try {
      final files = await PdfUtils.splitPdfByPageCount(
        filePath: result.files.single.path!,
        pageCount: 1,
      );
      widget.onStatusChange('Split complete. Generated ${files.length} files.');
      if (files.isNotEmpty) {
        await OpenFilex.open(files.first.path);
      }
    } catch (e) {
      widget.onStatusChange('Error splitting PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeatureCard(
      title: 'Split PDF',
      description: 'Divide a large PDF into multiple documents.',
      icon: Icons.unfold_less,
      onPressed: _splitPdf,
      color: Colors.cyan.shade50,
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
              Icon(icon, size: 40, color: Colors.cyan.shade700),
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
