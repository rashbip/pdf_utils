import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Utils Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PDF Utils Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _statusMessage;
  List<String> _extractedImages = [];

  Future<void> _generateInvoice() async {
    setState(() => _statusMessage = 'Generating Invoice...');
    try {
      final invoice = Invoice(
        supplier: const Supplier(
          name: 'BIP Scanner',
          address: '123 Tech Street, Silicon Valley',
          paymentInfo: 'PayPal: pay@bip.com',
          website: 'www.bipscanner.com',
        ),
        customer: const Customer(
          name: 'Happy Client',
          address: '456 User Lane, App City',
        ),
        info: InvoiceInfo(
          date: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 14)),
          description: 'Software Development Services',
          number: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        ),
        items: [
          InvoiceItem(
            description: 'Flutter Plugin Development',
            date: DateTime.now(),
            quantity: 1,
            vat: 0.15,
            unitPrice: 1500.0,
          ),
          InvoiceItem(
            description: 'Testing & Documentation',
            date: DateTime.now(),
            quantity: 2,
            vat: 0.15,
            unitPrice: 250.0,
          ),
        ],
      );

      final file = await PdfInvoiceGenerator.generate(invoice);
      setState(() {
        _statusMessage = 'Invoice generated: ${file.path}';
        _extractedImages = [];
      });
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  Future<void> _convertImagesToPdf() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isEmpty) return;

    setState(() => _statusMessage = 'Converting ${images.length} images to PDF...');
    try {
      final file = await PdfUtils.imagesToPdf(
        imagePaths: images.map((e) => e.path).toList(),
        outputFileName: 'converted_images_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _statusMessage = 'PDF created: ${file.path}';
        _extractedImages = [];
      });
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  Future<void> _extractPdfToImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    final pdfPath = result.files.single.path!;
    final appDir = await getApplicationDocumentsDirectory();
    final outputDir = '${appDir.path}/extracted_${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _statusMessage = 'Extracting pages from PDF...');
    try {
      final imagePaths = await PdfUtils.pdfToImages(
        pdfPath: pdfPath,
        outputDirectory: outputDir,
        onProgress: (current, total) {
          setState(() {
            _statusMessage = 'Extracting: $current / $total';
          });
        },
      );

      setState(() {
        _statusMessage = 'Extracted ${imagePaths.length} images to $outputDir';
        _extractedImages = imagePaths;
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'PDF Utils Functionalities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              _buildFeatureCard(
                title: 'Professional Invoice',
                description: 'Generate high-quality PDF invoices from structured data.',
                icon: Icons.receipt_long,
                onPressed: _generateInvoice,
                color: Colors.blue.shade50,
              ),
              const SizedBox(height: 15),
              
              _buildFeatureCard(
                title: 'Images to PDF',
                description: 'Select multiple images and combine them into a single PDF.',
                icon: Icons.picture_as_pdf,
                onPressed: _convertImagesToPdf,
                color: Colors.green.shade50,
              ),
              const SizedBox(height: 15),
              
              _buildFeatureCard(
                title: 'PDF to Images',
                description: 'Extract each page of a PDF file as a separate JPEG image.',
                icon: Icons.image,
                onPressed: _extractPdfToImages,
                color: Colors.orange.shade50,
              ),
              
              const SizedBox(height: 30),
              if (_statusMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                
              if (_extractedImages.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Extracted Previews:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _extractedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_extractedImages[index]),
                            fit: BoxFit.cover,
                            width: 100,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
              Icon(icon, size: 40, color: Colors.black54),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
