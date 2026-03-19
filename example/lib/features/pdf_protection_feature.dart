import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

class PdfProtectionFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const PdfProtectionFeature({super.key, required this.onStatusChange});

  @override
  State<PdfProtectionFeature> createState() => _PdfProtectionFeatureState();
}

class _PdfProtectionFeatureState extends State<PdfProtectionFeature> {
  Future<void> _protectPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Protecting PDF (Password: 1234)...');
    try {
      final file = await PdfUtils.protectPdf(
        inputPath: result.files.single.path!,
        password: '1234',
        outputFileName: 'protected_${DateTime.now().millisecondsSinceEpoch}',
      );
      widget.onStatusChange('Protected PDF: ${file.path}');
      await OpenFilex.open(file.path);
    } catch (e) {
      widget.onStatusChange('Error protecting PDF: $e');
    }
  }

  Future<void> _unlockPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Unlocking PDF (Password: 1234)...');
    try {
      final file = await PdfUtils.unlockPdf(
        inputPath: result.files.single.path!,
        password: '1234',
        outputFileName: 'unlocked_${DateTime.now().millisecondsSinceEpoch}',
      );
      widget.onStatusChange('Unlocked PDF: ${file.path}');
      await OpenFilex.open(file.path);
    } catch (e) {
      widget.onStatusChange('Error unlocking PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(
          title: 'Protect PDF (Lock)',
          description: 'Add password "1234" to your PDF.',
          icon: Icons.lock,
          onPressed: _protectPdf,
          color: Colors.red.shade50,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Remove Password (Unlock)',
          description: 'Unlock PDF protected with "1234".',
          icon: Icons.lock_open,
          onPressed: _unlockPdf,
          color: Colors.pink.shade50,
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
              Icon(icon, size: 40, color: Colors.red.shade700),
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
