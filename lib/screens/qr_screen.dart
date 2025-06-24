import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatelessWidget {
  final Task task;

  const QrScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Exclude user-specific data from the QR code for privacy/generality
    final Map<String, dynamic> taskData = {
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate?.toIso8601String(),
    };
    final String qrData = jsonEncode(taskData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bagikan Tugas'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 24),
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Pindai QR code ini untuk menyalin tugas.'),
          ],
        ),
      ),
    );
  }
} 