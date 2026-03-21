import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:file_picker/file_picker.dart';

class ThumbnailsFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const ThumbnailsFeature({super.key, required this.onStatusChange});

  @override
  State<ThumbnailsFeature> createState() => _ThumbnailsFeatureState();
}

class _ThumbnailsFeatureState extends State<ThumbnailsFeature> {
  List<File> _thumbs = [];
  bool _isProcessing = false;

  Future<void> _generateThumbnails() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _isProcessing = true;
      _thumbs = [];
    });
    widget.onStatusChange('Generating thumbnails...');

    try {
      final thumbs = await PdfUtils.getPdfThumbnails(
        filePath: result.files.single.path!,
        scale: 0.5,
        quality: 50,
      );
      
      setState(() {
        _thumbs = thumbs;
        _isProcessing = false;
      });
      widget.onStatusChange('Generated ${thumbs.length} thumbnails.');
    } catch (e) {
      setState(() => _isProcessing = false);
      widget.onStatusChange('Error generating thumbnails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(
          title: 'Lightweight Thumbnails',
          description: 'Extract fast, low-res page previews.',
          icon: Icons.auto_awesome_motion_rounded,
          onPressed: _generateThumbnails,
          color: Colors.orange.shade50,
          isProcessing: _isProcessing,
        ),
        if (_thumbs.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: _thumbs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.file(_thumbs[index], height: 100, width: 70, fit: BoxFit.cover),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isProcessing = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: color,
      child: InkWell(
        onTap: isProcessing ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.orange.shade800),
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
              if (isProcessing)
                const CircularProgressIndicator()
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
