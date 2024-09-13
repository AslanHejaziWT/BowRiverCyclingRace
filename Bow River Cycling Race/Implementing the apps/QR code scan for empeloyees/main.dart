import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRScannerPage(),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Database? database;

  List<Map<String, dynamic>> scannedData = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  // Initialize the database
  Future<void> _initializeDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'scanned_data.db');

    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE scans(id INTEGER PRIMARY KEY, content TEXT, timestamp TEXT)',
        );
      },
    );
    _loadScannedData();
  }

  // Load data from the database
  Future<void> _loadScannedData() async {
    final List<Map<String, dynamic>> data =
        await database!.query('scans', orderBy: 'timestamp DESC');
    setState(() {
      scannedData = data;
    });
  }

  // Save scan result to the database
  Future<void> _saveScan(String content) async {
    final timestamp = DateTime.now().toIso8601String();
    await database!
        .insert('scans', {'content': content, 'timestamp': timestamp});
    _loadScannedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: scannedData.length,
              itemBuilder: (context, index) {
                final item = scannedData[index];
                return ListTile(
                  title: Text(item['content']),
                  subtitle: Text(item['timestamp']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      _saveScan(scanData.code ?? '');
      controller.resumeCamera();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
