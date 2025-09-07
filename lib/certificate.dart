import 'package:flutter/material.dart';

class CertificatePage extends StatelessWidget {
  final String courseTitle;
  final String userName;
  final DateTime completionDate;

  const CertificatePage({
    Key? key,
    required this.courseTitle,
    required this.userName,
    required this.completionDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = "${completionDate.day}/${completionDate.month}/${completionDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate of Completion'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple, width: 4),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Certificate of Completion',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'This is to certify that',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'has successfully completed the course',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                courseTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Date of Completion: $formattedDate',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Container(
                width: 200,
                height: 2,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 8),
              const Text(
                'Authorized Signature',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.deepPurple,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
