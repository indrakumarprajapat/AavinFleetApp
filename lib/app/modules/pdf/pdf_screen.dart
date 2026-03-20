import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfScreen extends StatelessWidget {

  const PdfScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Route PDF"),
      ),

      body: SfPdfViewer.network(
        "https://www.africau.edu/images/default/sample.pdf",
      ),
    );
  }
}