import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_application_1/providers/task_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class ScannerScreen extends StatefulWidget {
  final String userId;
  const ScannerScreen({super.key, required this.userId});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null) {
        try {
          final data = jsonDecode(rawValue) as Map<String, dynamic>;
          final taskToImport = Task(
            userId: widget.userId,
            title: data['title'] ?? 'Tanpa Judul',
            description: data['description'],
            dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
          );
          _showConfirmationDialog(taskToImport);
        } catch (e) {
          _showErrorDialog('QR Code tidak valid.');
        }
      }
    }
  }

  Future<void> _showConfirmationDialog(Task task) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Impor Tugas?'),
          content: Text('Tambahkan "${task.title}" ke daftar tugas Anda?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() { _isProcessing = false; });
              },
            ),
            TextButton(
              child: const Text('Impor'),
              onPressed: () {
                Provider.of<TaskProvider>(context, listen: false).addTask(task);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() { _isProcessing = false; });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pindai QR Code')),
      body: MobileScanner(
        controller: controller,
        onDetect: _onDetect,
      ),
    );
  }
} 