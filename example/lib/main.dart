import 'package:flutter/material.dart';
import 'screens/invoice_screen.dart';
import 'screens/image_to_pdf_screen.dart';
import 'screens/pdf_to_image_screen.dart';
import 'screens/merge_pdf_screen.dart';
import 'screens/pdf_protection_screen.dart';
import 'screens/text_extraction_screen.dart';

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
                'PDF Utils (Standalone)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              _buildFeatureCard(
                title: 'Professional Invoice',
                description: 'Generate high-quality PDF invoices.',
                icon: Icons.receipt_long,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceScreen())),
                color: Colors.blue.shade50,
              ),
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                title: 'Images to PDF',
                description: 'Fast, native conversion of images to PDF.',
                icon: Icons.picture_as_pdf,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageToPdfScreen())),
                color: Colors.green.shade50,
              ),
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                title: 'PDF to Images',
                description: 'Extract pages as separate JPEGs or Long Image.',
                icon: Icons.image,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfToImageScreen())),
                color: Colors.orange.shade50,
              ),
              const SizedBox(height: 12),

              _buildFeatureCard(
                title: 'Merge & Split PDFs',
                description: 'Combine multiple PDF files or select specific pages.',
                icon: Icons.merge_type,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MergePdfScreen())),
                color: Colors.purple.shade50,
              ),
              const SizedBox(height: 12),

              _buildFeatureCard(
                title: 'PDF Protection',
                description: 'Add or remove password protection.',
                icon: Icons.lock,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfProtectionScreen())),
                color: Colors.red.shade50,
              ),
              const SizedBox(height: 12),

              _buildFeatureCard(
                title: 'Text & Metadata',
                description: 'Extract text, info, and author data.',
                icon: Icons.text_snippet,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TextExtractionScreen())),
                color: Colors.teal.shade50,
              ),
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
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
