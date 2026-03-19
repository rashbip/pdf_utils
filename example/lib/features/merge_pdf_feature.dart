import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

class MergePdfFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const MergePdfFeature({super.key, required this.onStatusChange});

  @override
  State<MergePdfFeature> createState() => _MergePdfFeatureState();
}

class _MergePdfFeatureState extends State<MergePdfFeature> {
  Future<void> _mergePdfs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final paths = result.files.map((e) => e.path!).toList();
    widget.onStatusChange('Merging ${paths.length} PDFs...');
    try {
      final file = await PdfUtils.mergePdfFiles(
        filesPath: paths,
        outputFileName: 'merged_${DateTime.now().millisecondsSinceEpoch}',
      );
      widget.onStatusChange('Merged PDF created: ${file.path}');
      await OpenFilex.open(file.path);
    } catch (e) {
      widget.onStatusChange('Error merging PDFs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeatureCard(
      title: 'Merge PDFs',
      description: 'Combine multiple PDF files into one.',
      icon: Icons.merge_type,
      onPressed: _mergePdfs,
      color: Colors.purple.shade50,
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
              Icon(icon, size: 40, color: Colors.purple.shade700),
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
