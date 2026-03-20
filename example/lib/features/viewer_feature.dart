import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:file_picker/file_picker.dart';

class ViewerFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const ViewerFeature({super.key, required this.onStatusChange});

  @override
  State<ViewerFeature> createState() => _ViewerFeatureState();
}

class _ViewerFeatureState extends State<ViewerFeature> {
  Future<void> _openViewer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BipPdfViewer(
          filePath: result.files.single.path!,
          title: result.files.single.name,
          themeColor: Colors.deepPurple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeatureCard(
      title: 'Advanced PDF Viewer',
      description: 'Open PDF with thumbnails, zoom, and print controls.',
      icon: Icons.menu_book_rounded,
      onPressed: _openViewer,
      color: Colors.deepPurple.shade50,
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
              Icon(icon, size: 40, color: Colors.deepPurple.shade700),
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
