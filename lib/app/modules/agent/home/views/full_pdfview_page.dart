import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FullPdfViewPage extends StatelessWidget {
  final String url;

  const FullPdfViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Route PDF"),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}