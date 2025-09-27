import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'app_state.dart';
import 'adminevents.dart' as admin;

class EventEnrollment {
  final String id;
  final String eventId;
  final String userName;
  final String email;
  final String phone;
  final String gender;
  final int age;
  final DateTime enrollmentDate;
  final String? certificateId;
  final bool certificateCompleted;
  final String status; // 'pending', 'approved', 'rejected'

  EventEnrollment({
    required this.id,
    required this.eventId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.age,
    required this.enrollmentDate,
    this.certificateId,
    this.certificateCompleted = false,
    this.status = 'pending',
  });
}

class AdminEventManagementPage extends StatefulWidget {
  final String? eventTitle;
  final String? eventId;
  final int? enrolledCount;
  
  const AdminEventManagementPage({
    super.key,
    this.eventTitle,
    this.eventId,
    this.enrolledCount,
  });

  @override
  State<AdminEventManagementPage> createState() => _AdminEventManagementPageState();
}

class _AdminEventManagementPageState extends State<AdminEventManagementPage> {
  bool _isUploading = false;
  
  final List<EventEnrollment> _dummyEnrollments = [
    EventEnrollment(
      id: '1',
      eventId: '1',
      userName: 'John Smith',
      email: 'john@example.com',
      phone: '+1234567890',
      gender: 'Male',
      age: 25,
      enrollmentDate: DateTime.now().subtract(Duration(days: 5)),
      certificateId: 'CERT-JAV-001',
      certificateCompleted: true,
      status: 'approved',
    ),
    EventEnrollment(
      id: '2',
      eventId: '1',
      userName: 'Sarah Johnson',
      email: 'sarah@example.com',
      phone: '+1234567891',
      gender: 'Female',
      age: 28,
      enrollmentDate: DateTime.now().subtract(Duration(days: 3)),
      certificateId: 'CERT-JAV-002',
      certificateCompleted: true,
      status: 'pending',
    ),
    EventEnrollment(
      id: '3',
      eventId: '1',
      userName: 'Mike Davis',
      email: 'mike@example.com',
      phone: '+1234567892',
      gender: 'Male',
      age: 22,
      enrollmentDate: DateTime.now().subtract(Duration(days: 2)),
      certificateId: 'CERT-JAV-003',
      certificateCompleted: false,
      status: 'pending',
    ),
    EventEnrollment(
      id: '4',
      eventId: '1',
      userName: 'Emma Wilson',
      email: 'emma@example.com',
      phone: '+1234567893',
      gender: 'Female',
      age: 26,
      enrollmentDate: DateTime.now().subtract(Duration(days: 1)),
      certificateId: 'CERT-JAV-004',
      certificateCompleted: true,
      status: 'approved',
    ),
    EventEnrollment(
      id: '5',
      eventId: '1',
      userName: 'Alex Brown',
      email: 'alex@example.com',
      phone: '+1234567894',
      gender: 'Male',
      age: 30,
      enrollmentDate: DateTime.now(),
      certificateCompleted: false,
      status: 'rejected',
    ),
  ];

  List<EventEnrollment> _enrollments = [];
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Approved', 'Pending', 'Rejected', 'Certificate Completed'];

  @override
  void initState() {
    super.initState();
    _enrollments = List.from(_dummyEnrollments);
  }

  List<EventEnrollment> get _filteredEnrollments {
    switch (_selectedFilter) {
      case 'Approved':
        return _enrollments.where((e) => e.status == 'approved').toList();
      case 'Pending':
        return _enrollments.where((e) => e.status == 'pending').toList();
      case 'Rejected':
        return _enrollments.where((e) => e.status == 'rejected').toList();
      case 'Certificate Completed':
        return _enrollments.where((e) => e.certificateCompleted).toList();
      default:
        return _enrollments;
    }
  }

  List<EventEnrollment> get _leaderboard {
    return _enrollments
        .where((e) => e.certificateCompleted)
        .toList()
      ..sort((a, b) => a.enrollmentDate.compareTo(b.enrollmentDate));
  }

  void _showUploadOverlay() {
    setState(() {
      _isUploading = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Success'),
          ],
        ),
        content: const Text('Event data successfully sent to SAI (Sports Authority of India)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.eventTitle ?? 'Event Management',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: _showUploadOverlay,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          _buildFilterRow(),
          Expanded(
            child: _buildMembersList(),
          ),
        ],
      ),
        ),
        if (_isUploading) _buildUploadOverlay(),
      ],
    );
  }

  Widget _buildUploadOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 0),
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange[200]!, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.orange[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'OFFICIAL TRANSMISSION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                        letterSpacing: 0.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sending to SAI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Sports Authority of India',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Event: ${widget.eventTitle ?? "Event"}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              decoration: TextDecoration.none,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Enrollment Data & Certificates',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.none,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Uploading data securely...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final totalEnrolled = _enrollments.length;
    final certificateCompleted = _enrollments.where((e) => e.certificateCompleted).length;
    final approved = _enrollments.where((e) => e.status == 'approved').length;
    final pending = _enrollments.where((e) => e.status == 'pending').length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.eventTitle ?? "Event"} Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Enrolled', totalEnrolled.toString(), Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Certificate Completed', certificateCompleted.toString(), Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatCard('Approved', approved.toString(), Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Pending', pending.toString(), Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Filter: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: _filterOptions.map((filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    final filteredList = _filteredEnrollments;
    
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No members found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final enrollment = filteredList[index];
        final rank = _selectedFilter == 'Certificate Completed' 
            ? _leaderboard.indexOf(enrollment) + 1 
            : null;
        return _buildMemberCard(enrollment, rank);
      },
    );
  }

  Widget _buildMemberCard(EventEnrollment enrollment, int? rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rank != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Text(
                  enrollment.userName[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrollment.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      enrollment.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(enrollment.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(Icons.phone, enrollment.phone),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(Icons.person, '${enrollment.gender}, ${enrollment.age}'),
              ),
            ],
          ),
          if (enrollment.certificateId != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  enrollment.certificateCompleted ? Icons.verified : Icons.pending,
                  size: 16,
                  color: enrollment.certificateCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Certificate: ${enrollment.certificateId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: enrollment.certificateCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (enrollment.certificateCompleted) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _viewProfile(enrollment),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('View'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              if (enrollment.status == 'pending') ...[
                TextButton.icon(
                  onPressed: () => _updateStatus(enrollment, 'approved'),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _updateStatus(enrollment, 'rejected'),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.orange;
        text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  void _updateStatus(EventEnrollment enrollment, String newStatus) {
    setState(() {
      final index = _enrollments.indexWhere((e) => e.id == enrollment.id);
      if (index != -1) {
        _enrollments[index] = EventEnrollment(
          id: enrollment.id,
          eventId: enrollment.eventId,
          userName: enrollment.userName,
          email: enrollment.email,
          phone: enrollment.phone,
          gender: enrollment.gender,
          age: enrollment.age,
          enrollmentDate: enrollment.enrollmentDate,
          certificateId: enrollment.certificateId,
          certificateCompleted: enrollment.certificateCompleted,
          status: newStatus,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${enrollment.userName} has been $newStatus'),
        backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
      ),
    );
  }

  void _viewProfile(EventEnrollment enrollment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${enrollment.userName} Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('Email', enrollment.email),
            _buildProfileRow('Phone', enrollment.phone),
            _buildProfileRow('Gender', enrollment.gender),
            _buildProfileRow('Age', enrollment.age.toString()),
            _buildProfileRow('Enrollment Date', 
                '${enrollment.enrollmentDate.day}/${enrollment.enrollmentDate.month}/${enrollment.enrollmentDate.year}'),
            if (enrollment.certificateId != null)
              _buildProfileRow('Certificate', enrollment.certificateId!),
            _buildProfileRow('Status', enrollment.status.toUpperCase()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() async {
    try {
      List<List<dynamic>> csvData = [
        ['Name', 'Email', 'Phone', 'Gender', 'Age', 'Enrollment Date', 'Certificate ID', 'Certificate Completed', 'Status']
      ];

      for (var enrollment in _filteredEnrollments) {
        csvData.add([
          enrollment.userName,
          enrollment.email,
          enrollment.phone,
          enrollment.gender,
          enrollment.age,
          '${enrollment.enrollmentDate.day}/${enrollment.enrollmentDate.month}/${enrollment.enrollmentDate.year}',
          enrollment.certificateId ?? 'N/A',
          enrollment.certificateCompleted ? 'Yes' : 'No',
          enrollment.status,
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/event_enrollments.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(file.path)], text: 'Event Enrollments Data');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV file exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}