import 'package:flutter/material.dart';

class Certificate {
  final String id;
  final String courseId;
  final String courseTitle;
  final String userName;
  final DateTime completionDate;

  Certificate({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.userName,
    required this.completionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'userName': userName,
      'completionDate': completionDate.toIso8601String(),
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      courseId: json['courseId'],
      courseTitle: json['courseTitle'],
      userName: json['userName'],
      completionDate: DateTime.parse(json['completionDate']),
    );
  }
}

class CertificateManager extends ChangeNotifier {
  static final CertificateManager _instance = CertificateManager._internal();
  factory CertificateManager() => _instance;
  CertificateManager._internal();

  final List<Certificate> _certificates = [];

  List<Certificate> get certificates => List.unmodifiable(_certificates);

  void addCertificate(String courseId, String courseTitle, String userName) {
    // Check if certificate already exists for this course
    final existingCertificate = _certificates.firstWhere(
      (cert) => cert.courseId == courseId && cert.userName == userName,
      orElse: () => Certificate(
        id: '',
        courseId: '',
        courseTitle: '',
        userName: '',
        completionDate: DateTime.now(),
      ),
    );

    if (existingCertificate.id.isEmpty) {
      // Certificate doesn't exist, create new one
      final certificate = Certificate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        courseId: courseId,
        courseTitle: courseTitle,
        userName: userName,
        completionDate: DateTime.now(),
      );
      _certificates.add(certificate);
      notifyListeners();
    }
  }

  bool hasCertificate(String courseId, String userName) {
    return _certificates.any(
      (cert) => cert.courseId == courseId && cert.userName == userName,
    );
  }

  Certificate? getCertificate(String courseId, String userName) {
    try {
      return _certificates.firstWhere(
        (cert) => cert.courseId == courseId && cert.userName == userName,
      );
    } catch (e) {
      return null;
    }
  }

  void removeDuplicateCertificates() {
    final seen = <String>{};
    _certificates.removeWhere((cert) {
      final key = '${cert.courseId}_${cert.userName}';
      if (seen.contains(key)) {
        return true; // Remove duplicate
      }
      seen.add(key);
      return false; // Keep first occurrence
    });
    notifyListeners();
  }
}
