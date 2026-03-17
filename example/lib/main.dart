import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Utils Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  Future<void> _generateInvoice() async {
    setState(() => _statusMessage = 'Generating Invoice...');
    try {
      final invoice = Invoice(
        supplier: const Supplier(
          name: 'BIP Scanner',
          address: '123 Tech Street, Silicon Valley',
          paymentInfo: 'PayPal: pay@bip.com',
        ),
        customer: const Customer(
          name: 'Happy Client',
          address: '456 User Lane, App City',
        ),
        info: InvoiceInfo(
          date: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 14)),
          description: 'Software Development Services',
          number: '2024-001',
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
      setState(() => _statusMessage = 'Invoice generated: ${file.path}');
      await OpenFilex.open(file.path);
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Demonstration of PDF Utils functionalities:',
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _generateInvoice,
                icon: const Icon(Icons.receipt),
                label: const Text('Generate Sample Invoice'),
              ),
              const SizedBox(height: 20),
              if (_statusMessage != null)
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
