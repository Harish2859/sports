import 'package:flutter/material.dart';
import 'models/scheme_model.dart';

class ExploreResultsPage extends StatelessWidget {
  final List<Scheme> results;
  final String searchQuery;

  const ExploreResultsPage({
    Key? key,
    required this.results,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: Text(
          '${results.length} Schemes Found',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: results.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              itemBuilder: (context, index) => _buildSchemeCard(results[index]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No schemes found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search filters',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(Scheme scheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    scheme.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(scheme.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    scheme.type,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scheme.organization,
              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              scheme.description,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    scheme.location,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                Icon(Icons.sports, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  scheme.sport,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Age: ${scheme.minAge}-${scheme.maxAge}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(Icons.home, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  scheme.programType,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            if (scheme.isForParaSport) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.accessible, size: 16, color: Colors.purple.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Para Sport Friendly',
                      style: TextStyle(color: Colors.purple.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                _buildDetailSection('Eligibility', scheme.eligibility),
                _buildDetailSection('Facilities', scheme.facilities),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Text('Application Deadline: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${scheme.applicationDeadline.day}/${scheme.applicationDeadline.month}/${scheme.applicationDeadline.year}',
                        style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Free Coaching':
        return Colors.green;
      case 'Scholarship':
        return Colors.blue;
      case 'Sponsorship':
        return Colors.orange;
      case 'Grant':
        return Colors.purple;
      case 'Event':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}