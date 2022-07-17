import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final url, name;
  const PdfViewer({this.url, this.name});

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
          backgroundColor: Theme.of(context).splashColor,
          title: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(widget.name, overflow: TextOverflow.ellipsis,),
          ),
          // centerTitle: true,
        ),
        body: Container(
            child: widget.url == null
                ? const Center(
                    child: Text('PDF'),
                  )
                : SfPdfViewer.network(
                    '${widget.url}',
                    key: _pdfViewerKey,
                  )));
  }
}
