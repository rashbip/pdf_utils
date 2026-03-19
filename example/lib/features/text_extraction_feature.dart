import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:file_picker/file_picker.dart';

class TextExtractionFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const TextExtractionFeature({super.key, required this.onStatusChange});

  @override
  State<TextExtractionFeature> createState() => _TextExtractionFeatureState();
}

class _TextExtractionFeatureState extends State<TextExtractionFeature> {
  Future<void> _extractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Extracting metadata...');
    try {
      final doc = await PDFDoc.fromPath(result.files.single.path!);
      final text = await doc.text;
      final info = doc.info;

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: Text(info.title ?? 'PDF Info'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Author: ${info.author ?? 'Unknown'}'),
                Text('Pages: ${doc.length}'),
                const Divider(),
                const Text('Extracted Text (Snippet):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(text.length > 500 ? '${text.substring(0, 500)}...' : text),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      widget.onStatusChange('Text extraction complete.');
    } catch (e) {
      widget.onStatusChange('Error extracting text: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeatureCard(
      title: 'Text & Metadata',
      description: 'Extract text, info, and author data.',
      icon: Icons.text_snippet,
      onPressed: _extractText,
      color: Colors.teal.shade50,
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
              Icon(icon, size: 40, color: Colors.teal.shade700),
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
