import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final url;
  const PdfViewer({this.url});

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF60c4b9),
          title: const Text("PDF"),
          centerTitle: true,
        ),
        body: Container(
            child: widget.url == null
                ? Center(
                    child: Text('PDF'),
                  )
                : SfPdfViewer.network(
                    '${widget.url}',
                    key: _pdfViewerKey,
                  )));
  }
}
