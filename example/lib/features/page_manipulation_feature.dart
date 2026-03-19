import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class PageManipulationFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const PageManipulationFeature({super.key, required this.onStatusChange});

  @override
  State<PageManipulationFeature> createState() => _PageManipulationFeatureState();
}

class _PageManipulationFeatureState extends State<PageManipulationFeature> {
  Future<void> _rotateFirstPage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Rotating first page by 90°...');
    try {
      final file = await PdfUtils.manipulatePages(
        filePath: result.files.single.path!,
        rotate: {1: 90},
      );
      if (file != null) {
        widget.onStatusChange('Rotated PDF: ${file.path}');
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      widget.onStatusChange('Error rotating PDF: $e');
    }
  }

  Future<void> _deleteSecondPage() async {
     FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Deleting second page...');
    try {
      final file = await PdfUtils.manipulatePages(
        filePath: result.files.single.path!,
        delete: [2],
      );
      if (file != null) {
        widget.onStatusChange('Modified PDF: ${file.path}');
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      widget.onStatusChange('Error deleting page: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(
          title: 'Rotate Page (90°)',
          description: 'Rotate the first page clockwise.',
          icon: Icons.rotate_right,
          onPressed: _rotateFirstPage,
          color: Colors.lime.shade50,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Delete Page 2',
          description: 'Quickly remove the second page.',
          icon: Icons.delete_sweep,
          onPressed: _deleteSecondPage,
          color: Colors.deepOrange.shade50,
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
              Icon(icon, size: 40, color: Colors.blueGrey.shade700),
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
