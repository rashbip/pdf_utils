import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

class PdfProtectionScreen extends StatefulWidget {
  const PdfProtectionScreen({super.key});

  @override
  State<PdfProtectionScreen> createState() => _PdfProtectionScreenState();
}

class _PdfProtectionScreenState extends State<PdfProtectionScreen> {
  String? _statusMessage;

  Future<void> _protectPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() => _statusMessage = 'Protecting PDF with password "1234"...');
    try {
      final file = await PdfUtils.protectPdf(
        inputPath: result.files.single.path!,
        password: '1234',
        outputFileName: 'protected_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _statusMessage = 'Protected PDF created: ${file.path} (Password: 1234)';
      });
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  Future<void> _unlockPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() => _statusMessage = 'Unlocking PDF with password "1234"...');
    try {
      final file = await PdfUtils.unlockPdf(
        inputPath: result.files.single.path!,
        password: '1234',
        outputFileName: 'unlocked_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _statusMessage = 'Unlocked PDF created: ${file.path}';
      });
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e. Make sure the password is correct.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Protection')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Add, remove, or check password protection for your PDF files.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _protectPdf,
              icon: const Icon(Icons.lock),
              label: const Text('Protect PDF (Password: 1234)'),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _unlockPdf,
              icon: const Icon(Icons.lock_open),
              label: const Text('Remove Password (Password: 1234)'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 20),
              Text(_statusMessage!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
