import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'pdf_utils.dart'; // For printPdf and enums

/// A basic customizable PDF reader wrapper around pdfx.
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

/// A high-level, feature-rich PDF Viewer with native feel and advanced controls.
class BipPdfViewer extends StatefulWidget {
  final String filePath;
  final String title;
  final Color? themeColor;
  final bool showPrint;
  final bool showThumbnails;
  
  const BipPdfViewer({
    super.key,
    required this.filePath,
    this.title = 'PDF Viewer',
    this.themeColor,
    this.showPrint = true,
    this.showThumbnails = true,
  });

  @override
  State<BipPdfViewer> createState() => _BipPdfViewerState();
}

class _BipPdfViewerState extends State<BipPdfViewer> {
  late PdfControllerPinch _controller;
  int _actualPage = 1;
  int _allPagesCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openFile(widget.filePath),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showThumbnails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ThumbnailsSheet(
        filePath: widget.filePath,
        totalCount: _allPagesCount,
        currentPage: _actualPage,
        onPageSelect: (page) {
          _controller.animateToPage(
            pageNumber: page, 
            duration: const Duration(milliseconds: 300), 
            curve: Curves.easeInOut
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.themeColor ?? theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          if (widget.showPrint)
            IconButton(
              icon: const Icon(Icons.print_outlined),
              onPressed: () => PdfUtils.printPdf(filePath: widget.filePath),
              tooltip: 'Print PDF',
            ),
          if (widget.showThumbnails)
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              onPressed: _showThumbnails,
              tooltip: 'Thumbnails',
            ),
        ],
      ),
      body: Stack(
        children: [
          PdfViewPinch(
            controller: _controller,
            onDocumentLoaded: (document) {
              setState(() {
                _allPagesCount = document.pagesCount;
              });
            },
            onPageChanged: (page) {
              setState(() => _actualPage = page);
            },
          ),
          
          // Slider and Indicator
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _CompactControls(
              currentPage: _actualPage,
              totalPages: _allPagesCount,
              controller: _controller,
              primaryColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PdfControllerPinch controller;
  final Color primaryColor;

  const _CompactControls({
    required this.currentPage,
    required this.totalPages,
    required this.controller,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page Navigation Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                onPressed: currentPage > 1 
                  ? () => controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease) 
                  : null,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // TODO: implement Page Jump dialog if needed
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$currentPage / $totalPages',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 30),
                onPressed: currentPage < totalPages 
                  ? () => controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease) 
                  : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Mini Slider
        if (totalPages > 1)
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: currentPage / totalPages,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ThumbnailsSheet extends StatefulWidget {
  final String filePath;
  final int totalCount;
  final int currentPage;
  final Function(int) onPageSelect;

  const _ThumbnailsSheet({
    required this.filePath,
    required this.totalCount,
    required this.currentPage,
    required this.onPageSelect,
  });

  @override
  State<_ThumbnailsSheet> createState() => _ThumbnailsSheetState();
}

class _ThumbnailsSheetState extends State<_ThumbnailsSheet> {
  Map<int, File> _thumbnails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnails();
  }

  Future<void> _loadThumbnails() async {
    try {
      final thumbs = await PdfUtils.getPdfThumbnails(
        filePath: widget.filePath,
        scale: 0.3, // Very lightweight for grid
      );
      if (mounted) {
        setState(() {
          for (int i = 0; i < thumbs.length; i++) {
            _thumbnails[i + 1] = thumbs[i];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Outline & Thumbnails', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          if (_isLoading && _thumbnails.isEmpty)
             const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!_isLoading || _thumbnails.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: widget.totalCount,
                itemBuilder: (context, index) {
                  final page = index + 1;
                  final isCurrent = page == widget.currentPage;
                  final thumb = _thumbnails[page];

                  return GestureDetector(
                    onTap: () => widget.onPageSelect(page),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isCurrent ? Colors.deepPurple : Colors.grey.shade300, 
                                width: isCurrent ? 2 : 1
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (thumb != null)
                                  Image.file(thumb, fit: BoxFit.cover)
                                else
                                  Center(child: Icon(Icons.description_rounded, color: Colors.grey.shade300, size: 40)),
                                if (isCurrent)
                                  Container(color: Colors.deepPurple.withOpacity(0.1)),
                                if (isCurrent)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Icon(Icons.check_circle_rounded, color: Colors.deepPurple, size: 18),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Page $page', 
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, 
                            color: isCurrent ? Colors.deepPurple : Colors.black87
                          )
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
