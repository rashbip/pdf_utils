import 'dart:io';
import 'package:flutter/material.dart';
import 'features/invoice_feature.dart';
import 'features/image_to_pdf_feature.dart';
import 'features/pdf_to_image_feature.dart';
import 'features/merge_pdf_feature.dart';
import 'features/pdf_protection_feature.dart';
import 'features/text_extraction_feature.dart';
import 'features/compression_feature.dart';
import 'features/watermark_feature.dart';
import 'features/split_feature.dart';
import 'features/page_manipulation_feature.dart';
import 'features/info_feature.dart';
import 'features/viewer_feature.dart';

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

  void _onStatusChange(String message, {List<String>? previews}) {
    setState(() {
      _statusMessage = message;
      if (previews != null) {
        _extractedImages = previews;
      }
    });
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
                'PDF Utils (Standalone v2.1)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'A single screen with modular feature components.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              
              InvoiceFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),
              
              ViewerFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),
              
              ImageToPdfFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),
              
              PdfToImageFeature(onProgress: (msg, {previews}) => _onStatusChange(msg, previews: previews)),
              const SizedBox(height: 12),

              MergePdfFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),

              PdfProtectionFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),

              TextExtractionFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),
              CompressionFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),
              WatermarkFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),
              SplitFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),
              PageManipulationFeature(onStatusChange: _onStatusChange),
              const SizedBox(height: 12),
              InfoFeature(onStatusChange: _onStatusChange),
              
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
                    style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
