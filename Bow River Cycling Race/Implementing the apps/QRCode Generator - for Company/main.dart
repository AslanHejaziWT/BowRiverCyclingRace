import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRCodeGenerator(),
    );
  }
}

class QRCodeGenerator extends StatefulWidget {
  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  TextEditingController textController = TextEditingController();
  String qrData = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter text to generate QR code',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  qrData = textController.text;
                });
              },
              child: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 20),
            if (qrData.isNotEmpty)
              Column(
                children: [
                  QrImage(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveAsPDF,
                    child: const Text('Save QR Code as PDF'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _printQRCode,
                    child: const Text('Print QR Code'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Method to save QR code as PDF
  Future<void> _saveAsPDF() async {
    final pdf = pw.Document();

    // Add QR code image to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: qrData,
              width: 200,
              height: 200,
            ),
          );
        },
      ),
    );

    // Save PDF file
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'qrcode.pdf',
    );
  }

  // Method to print the QR code
  Future<void> _printQRCode() async {
    final pdf = pw.Document();

    // Add QR code image to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: qrData,
              width: 200,
              height: 200,
            ),
          );
        },
      ),
    );

    // Print the document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
