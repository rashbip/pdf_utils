import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

class WatermarkFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const WatermarkFeature({super.key, required this.onStatusChange});

  @override
  State<WatermarkFeature> createState() => _WatermarkFeatureState();
}

class _WatermarkFeatureState extends State<WatermarkFeature> {
  Future<void> _watermarkPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Watermarking PDF...');
    try {
      final file = await PdfUtils.addWatermark(
        filePath: result.files.single.path!,
        text: '{image} BIP SCANNER',
        imagePath: r'D:\Android\flutter_projects\bip_scanner\plugins\pdf_utils\example\assets\logo.png',
        color: '#FF0000',
        backgroundColor: '#FFFFE0', // Light yellow background
        opacity: 0.2,
        fontSize: 30,
        placement: PdfWatermarkPlacement.center,
      );
      if (file != null) {
        widget.onStatusChange('PDF Watermarked: ${file.path}');
        await OpenFilex.open(file.path);
      } else {
        widget.onStatusChange('Watermarking failed.');
      }
    } catch (e) {
      widget.onStatusChange('Error watermarking PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeatureCard(
      title: 'Watermark PDF',
      description: 'Add text watermark and branding.',
      icon: Icons.branding_watermark,
      onPressed: _watermarkPdf,
      color: Colors.indigo.shade50,
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
