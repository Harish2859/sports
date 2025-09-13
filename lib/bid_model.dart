import 'package:flutter/material.dart';

class Bid {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime createdAt;
  final String status;
  final String? userId;
  final String? category;
  final DateTime? expiresAt;
  final String? performanceId;
  final double? requiredScore;

  Bid({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.createdAt,
    this.status = 'active',
    this.userId,
    this.category,
    this.expiresAt,
    this.performanceId,
    this.requiredScore,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'active',
      userId: json['userId'],
      category: json['category'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      performanceId: json['performanceId'],
      requiredScore: json['requiredScore']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'userId': userId,
      'category': category,
      'expiresAt': expiresAt?.toIso8601String(),
      'performanceId': performanceId,
      'requiredScore': requiredScore,
    };
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isActive => status == 'active' && !isExpired;
  
  Color get statusColor {
    switch (status) {
      case 'active': return Colors.green;
      case 'pending': return Colors.orange;
      case 'completed': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}