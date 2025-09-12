import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_layout.dart';
import 'theme_provider.dart';
import 'certificate_manager.dart';

class MyCertificatesPage extends StatelessWidget {
  const MyCertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final certificateManager = CertificateManager();
    final certificates = certificateManager.certificates;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    // Add dummy certificates if none exist
    final dummyCertificates = [
      {
        'id': 'CERT-JAV-001',
        'courseTitle': 'Javelin Certificate',
        'completionDate': DateTime.now().subtract(const Duration(days: 30)),
        'issuer': 'Athletics Federation',
      },
      {
        'id': 'CERT-ATH-002', 
        'courseTitle': 'Athletics Certificate',
        'completionDate': DateTime.now().subtract(const Duration(days: 60)),
        'issuer': 'Sports Authority',
      },
      {
        'id': 'CERT-SWM-003',
        'courseTitle': 'Swimming Certificate',
        'completionDate': DateTime.now().subtract(const Duration(days: 90)),
        'issuer': 'Aquatic Sports Board',
      },
      {
        'id': 'CERT-GEN-004',
        'courseTitle': 'General Sports Certificate',
        'completionDate': DateTime.now().subtract(const Duration(days: 120)),
        'issuer': 'National Sports Council',
      },
    ];
    
    final allCertificates = certificates.isEmpty ? dummyCertificates : certificates;

    return MainLayout(
      currentIndex: 4, // Profile tab
      onTabChanged: (index) {
        if (index != 4) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
          body: allCertificates.isEmpty
          ? Center(
              child: Text(
                'No certificates earned yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allCertificates.length,
              itemBuilder: (context, index) {
                final cert = allCertificates[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.card_membership, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                (cert as Map<String, dynamic>)['courseTitle'] ?? 'Course Title',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Issued by Fair Play Academy',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
  }
}
