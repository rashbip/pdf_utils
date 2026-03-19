import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:file_picker/file_picker.dart';

class InfoFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const InfoFeature({super.key, required this.onStatusChange});

  @override
  State<InfoFeature> createState() => _InfoFeatureState();
}

class _InfoFeatureState extends State<InfoFeature> {
  Future<void> _checkValidity() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Analyzing PDF...');
    try {
      final validity = await PdfUtils.getValidity(result.files.single.path!);
      if (validity != null) {
        String msg = 'Is Valid: ${validity.isValid}\n'
            'Open Protected: ${validity.isOpenPasswordProtected}\n'
            'Printing Allowed: ${validity.isPrintingAllowed}\n'
            'Modifying Allowed: ${validity.isModifyContentsAllowed}';
        widget.onStatusChange(msg);
      }
    } catch (e) {
      widget.onStatusChange('Error checking validity: $e');
    }
  }

  Future<void> _getPageSizes() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Fetching page sizes...');
    try {
      final sizes = await PdfUtils.getPagesSize(result.files.single.path!);
      String msg = 'Found ${sizes.length} pages:';
      for (var size in sizes.take(5)) {
        msg += '\nPage ${size.pageNumber}: ${size.width.toInt()}x${size.height.toInt()}';
      }
      if (sizes.length > 5) msg += '\n... and ${sizes.length - 5} more.';
      widget.onStatusChange(msg);
    } catch (e) {
      widget.onStatusChange('Error getting page sizes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(
          title: 'Check Validity & Security',
          description: 'Analyze PDF structure and security settings.',
          icon: Icons.security,
          onPressed: _checkValidity,
          color: Colors.indigo.shade50,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Get Page Sizes',
          description: 'Retrieve dimensions of all pages in the PDF.',
          icon: Icons.photo_size_select_actual,
          onPressed: _getPageSizes,
          color: Colors.teal.shade50,
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
              Icon(icon, size: 40, color: Colors.indigo.shade700),
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
