import 'package:classmate/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

class PDFViewerPage extends StatefulWidget {
  final String url;
  const PDFViewerPage({super.key, required this.url});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late Future<PdfDocument> _futureDocument;

  Future<PdfDocument> loadDocument() async {
    final workingUrl = "${AppConfig.mainServerBaseUrl}${widget.url}";
    final response = await http.get(Uri.parse(workingUrl));
    if (response.statusCode == 200) {
      return PdfDocument.openData(response.bodyBytes);
    } else {
      throw Exception("Failed to load PDF");
    }
  }

  @override
  void initState() {
    super.initState();
    _futureDocument = loadDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: Colors.black87, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "PDF Viewer",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<PdfDocument>(
        future: _futureDocument,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final document = snapshot.data!;
            return PdfViewPinch(
              controller: PdfControllerPinch(
                document: Future.value(document),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
