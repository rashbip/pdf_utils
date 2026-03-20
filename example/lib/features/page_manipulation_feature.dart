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

  Future<void> _reorderPages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Swapping first two pages...');
    try {
      final file = await PdfUtils.manipulatePages(
        filePath: result.files.single.path!,
        // This will swap the first two pages and keep them as the only pages
        // To keep all pages in a real app, you'd get the full page count first
        reorder: [2, 1], 
      );
      if (file != null) {
        widget.onStatusChange('Reordered PDF: ${file.path}');
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      widget.onStatusChange('Error reordering PDF: $e');
    }
  }

  Future<void> _insertPage() async {
    FilePickerResult? sourceResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (sourceResult == null || sourceResult.files.single.path == null) return;

    // Pick an image or PDF to insert
    FilePickerResult? insertResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (insertResult == null || insertResult.files.single.path == null) return;

    widget.onStatusChange('Inserting page after first page...');
    try {
      final file = await PdfUtils.addPage(
        filePath: sourceResult.files.single.path!,
        insertPath: insertResult.files.single.path!,
        afterPage: 1, 
      );
      if (file != null) {
        widget.onStatusChange('Inserted PDF: ${file.path}');
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      widget.onStatusChange('Error inserting page: $e');
    }
  }

  Future<void> _resizePdfToA4() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Resizing to A4 (595x842)...');
    try {
      final file = await PdfUtils.resizePdf(
        filePath: result.files.single.path!,
        width: 595, // A4 width in points
        height: 842, // A4 height in points
      );
      if (file != null) {
        widget.onStatusChange('Resized PDF: ${file.path}');
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      widget.onStatusChange('Error resizing PDF: $e');
    }
  }

  Future<void> _removeBlankPages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Detecting and removing blank pages...');
    try {
      final file = await PdfUtils.removeBlankPages(
        filePath: result.files.single.path!,
      );
      if (file != null) {
        widget.onStatusChange('Cleaned PDF: ${file.path}');
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      widget.onStatusChange('Error removing blank pages: $e');
    }
  }

  Future<void> _addPageNumbers() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Adding page numbers to bottom center...');
    try {
      final file = await PdfUtils.addPageNumbers(
        filePath: result.files.single.path!,
        customText: '{image} Report - Page {n} of {total}',
        imagePath: r'D:\Android\flutter_projects\bip_scanner\plugins\pdf_utils\example\assets\logo.png',
        fontSize: 10,
        placement: PdfTextPlacement.bottomRight,
      );
      if (file != null) {
        widget.onStatusChange('Numbered PDF: ${file.path}');
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      widget.onStatusChange('Error adding page numbers: $e');
    }
  }

  Future<void> _printPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    widget.onStatusChange('Opening system print dialog...');
    try {
      await PdfUtils.printPdf(
        filePath: result.files.single.path!,
        jobName: 'BipScanner_Document',
      );
      widget.onStatusChange('Print dialog finished.');
    } catch (e) {
      widget.onStatusChange('Error printing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(
          title: 'Print PDF',
          description: 'Open the system print dialog for a document.',
          icon: Icons.print,
          onPressed: _printPdf,
          color: Colors.blueGrey.shade50,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Add Page Numbers',
          description: 'Apply custom numbering with {n} and {total} tags.',
          icon: Icons.format_list_numbered,
          onPressed: _addPageNumbers,
          color: Colors.indigo.shade50,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Remove Blank Pages',
          description: 'Smart detection of emtpy/blank pages.',
          icon: Icons.auto_delete,
          onPressed: _removeBlankPages,
          color: Colors.red.shade50,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Resize to A4',
          description: 'Scale all pages to fit A4 (centered, white bg).',
          icon: Icons.aspect_ratio,
          onPressed: _resizePdfToA4,
          color: Colors.purple.shade50,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Insert Page',
          description: 'Insert an image or PDF after the first page.',
          icon: Icons.add_circle_outline,
          onPressed: _insertPage,
          color: Colors.green.shade50,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Swap First Two Pages',
          description: 'Reorder pages 1 and 2 (and keep only those).',
          icon: Icons.swap_vert,
          onPressed: _reorderPages,
          color: Colors.blue.shade50,
        ),
        const SizedBox(height: 12),
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
