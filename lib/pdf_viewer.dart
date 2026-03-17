import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

/// A customizable PDF viewer widget exposed by pdf_utils.
class PdfReader extends StatefulWidget {
  final String pdfPath;
  final PdfControllerPinch? controller;
  final Axis scrollDirection;
  final void Function(int)? onPageChanged;
  final void Function(PdfDocument)? onDocumentLoaded;
  final void Function(Object)? onDocumentError;

  const PdfReader({
    super.key,
    required this.pdfPath,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.onPageChanged,
    this.onDocumentLoaded,
    this.onDocumentError,
  });

  @override
  State<PdfReader> createState() => _PdfReaderState();
}

class _PdfReaderState extends State<PdfReader> {
  late PdfControllerPinch _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ??
        PdfControllerPinch(document: PdfDocument.openFile(widget.pdfPath));
  }

  @override
  void dispose() {
    // Only dispose if we created it internally
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfViewPinch(
      controller: _internalController,
      scrollDirection: widget.scrollDirection,
      onPageChanged: widget.onPageChanged,
      onDocumentLoaded: widget.onDocumentLoaded,
      onDocumentError: widget.onDocumentError,
    );
  }
}
