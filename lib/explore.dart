import 'package:flutter/material.dart';
import 'services/scheme_service.dart';
import 'models/scheme_model.dart';
import 'explore_results.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();
  String? _selectedSport;
  String? _selectedType;
  String? _selectedLocation;
  int? _maxAge;
  bool? _isForParaSport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Explore Sports Schemes',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildFilters(),
                const SizedBox(height: 30),
                _buildFeaturedSchemes(),
              ],
            ),
          ),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search schemes, sports, locations...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filters',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSport,
                decoration: _filterDecoration('Sport'),
                items: SchemeService.getSports()
                    .map((sport) => DropdownMenuItem(value: sport, child: Text(sport)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSport = value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: _filterDecoration('Type'),
                items: SchemeService.getTypes()
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: _filterDecoration('Location'),
          onChanged: (value) => _selectedLocation = value.isEmpty ? null : value,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: _filterDecoration('Max Age'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _maxAge = int.tryParse(value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<bool>(
                value: _isForParaSport,
                decoration: _filterDecoration('Para Sport'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: true, child: Text('Para Sport')),
                  DropdownMenuItem(value: false, child: Text('Regular')),
                ],
                onChanged: (value) => setState(() => _isForParaSport = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedSchemes() {
    final schemes = SchemeService.getAllSchemes().take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Schemes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...schemes.map((scheme) => _buildSchemeCard(scheme)),
      ],
    );
  }

  Widget _buildSchemeCard(Scheme scheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    scheme.type,
                    style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scheme.organization,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              scheme.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(scheme.location, style: TextStyle(color: Colors.grey.shade600)),
                const Spacer(),
                Icon(Icons.sports, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(scheme.sport, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _performSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Search Schemes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  InputDecoration _filterDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  void _performSearch() {
    final results = SchemeService.searchSchemes(
      sport: _selectedSport,
      location: _selectedLocation,
      type: _selectedType,
      maxAge: _maxAge,
      isForParaSport: _isForParaSport,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExploreResultsPage(
          results: results,
          searchQuery: _searchController.text,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}