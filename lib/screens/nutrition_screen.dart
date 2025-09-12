import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nutrition_model.dart';
import '../theme_provider.dart';
import '../services/location_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController _queryController = TextEditingController();
  final List<NutritionSuggestion> _suggestions = [];
  NutritionSuggestion? _currentSuggestion;
  bool _isLoading = false;
  
  final AthleteProfile _profile = AthleteProfile(
    id: '1',
    name: 'John Athlete',
    sport: 'Running',
    weight: 70.0,
    height: 175.0,
    age: 25,
    trainingGoal: 'Endurance Training',
  );
  
  LocationContext _location = LocationContext(
    city: 'Unknown',
    country: 'Unknown',
    climate: 'Unknown',
    localFoods: [],
  );
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      setState(() {
        _location = location;
      });
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildLocationSelector(),
    );
  }

  Widget _buildLocationSelector() {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final locations = [
      {'city': 'New York', 'country': 'USA'},
      {'city': 'Mumbai', 'country': 'India'},
      {'city': 'Toronto', 'country': 'Canada'},
      {'city': 'Sydney', 'country': 'Australia'},
      {'city': 'London', 'country': 'UK'},
      {'city': 'Rio de Janeiro', 'country': 'Brazil'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.my_location, color: Colors.blue),
            title: const Text('Use Current Location'),
            onTap: () {
              Navigator.pop(context);
              _getCurrentLocation();
            },
          ),
          const Divider(),
          ...locations.map((loc) => ListTile(
            leading: const Icon(Icons.location_on),
            title: Text('${loc['city']}, ${loc['country']}'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _location = LocationContext(
                  city: loc['city']!,
                  country: loc['country']!,
                  climate: LocationService.getClimateForCountry(loc['country']!),
                  localFoods: LocationService.getLocalFoods(loc['country']!),
                  isAutoDetected: false,
                );
              });
            },
          )),
        ],
      ),
    );
  }

  void _submitQuery() {
    if (_queryController.text.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      final suggestion = _generateSuggestion(_queryController.text.trim());
      setState(() {
        _currentSuggestion = suggestion;
        _isLoading = false;
      });
    });
  }
  
  NutritionSuggestion _generateSuggestion(String query) {
    // Simple mock AI responses
    Map<String, Map<String, dynamic>> responses = {
      'before training': {
        'food': 'Banana with Oatmeal',
        'portion': '1 medium banana + 1/2 cup oats',
        'calories': 280,
        'protein': 8.0,
        'carbs': 58.0,
        'fat': 4.0,
        'reason': 'Provides quick energy and sustained carbs for endurance training'
      },
      'recovery': {
        'food': 'Chocolate Milk',
        'portion': '1 cup (240ml)',
        'calories': 190,
        'protein': 8.0,
        'carbs': 26.0,
        'fat': 8.0,
        'reason': 'Perfect 3:1 carb to protein ratio for muscle recovery'
      },
      'hydration': {
        'food': 'Coconut Water',
        'portion': '1 cup (240ml)',
        'calories': 45,
        'protein': 2.0,
        'carbs': 9.0,
        'fat': 0.5,
        'reason': 'Natural electrolytes for hot weather hydration'
      },
    };
    
    String key = 'before training';
    if (query.toLowerCase().contains('recovery')) key = 'recovery';
    if (query.toLowerCase().contains('hydration')) key = 'hydration';
    
    final data = responses[key]!;
    return NutritionSuggestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      query: query,
      foodName: data['food'],
      portionSize: data['portion'],
      calories: data['calories'],
      protein: data['protein'],
      carbs: data['carbs'],
      fat: data['fat'],
      reason: data['reason'],
      timestamp: DateTime.now(),
    );
  }
  
  void _saveSuggestion() {
    if (_currentSuggestion != null) {
      setState(() {
        _currentSuggestion!.isSaved = true;
        _suggestions.insert(0, _currentSuggestion!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Athlete Nutrition Assistant'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(isDarkMode),
              const SizedBox(height: 16),
              _buildQueryInput(isDarkMode),
              const SizedBox(height: 16),
              if (_isLoading) _buildLoadingCard(isDarkMode),
              if (_currentSuggestion != null && !_isLoading) _buildSuggestionCard(isDarkMode),
              const SizedBox(height: 16),
              _buildLocationCard(isDarkMode),
              const SizedBox(height: 16),
              _buildHistorySection(isDarkMode),
              const SizedBox(height: 16),
              _buildFooter(isDarkMode),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Text(_profile.name[0], style: const TextStyle(fontSize: 24, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_profile.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                Text('${_profile.sport} • ${_profile.age}y • ${_profile.weight}kg • ${_profile.height}cm', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600])),
                Text(_profile.trainingGoal, style: TextStyle(color: Colors.blue, fontSize: 12)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        ],
      ),
    );
  }
  
  Widget _buildQueryInput(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ask for Nutrition Suggestion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
          const SizedBox(height: 12),
          TextField(
            controller: _queryController,
            decoration: InputDecoration(
              hintText: 'e.g., What should I eat before training?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 2,
            minLines: 1,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitQuery,
              child: const Text('Get Suggestion'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating personalized suggestion...'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestionCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrition Recommendation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
          const SizedBox(height: 12),
          Text(_currentSuggestion!.foodName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue)),
          Text('Portion: ${_currentSuggestion!.portionSize}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600])),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientInfo('Calories', '${_currentSuggestion!.calories}', Colors.orange),
              _buildNutrientInfo('Protein', '${_currentSuggestion!.protein}g', Colors.red),
              _buildNutrientInfo('Carbs', '${_currentSuggestion!.carbs}g', Colors.blue),
              _buildNutrientInfo('Fat', '${_currentSuggestion!.fat}g', Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Text(_currentSuggestion!.reason, style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700], fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveSuggestion,
            child: const Text('Save to Profile'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  Widget _buildLocationCard(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Location Context', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                Row(
                  children: [
                    if (_location.isAutoDetected) 
                      const Icon(Icons.my_location, size: 16, color: Colors.green),
                    IconButton(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: _showLocationSelector,
                      icon: const Icon(Icons.edit_location, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoadingLocation)
              const Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Detecting location...'),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_location.city}, ${_location.country} • ${_location.climate}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('Local foods: ${_location.localFoods.join(', ')}', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600])),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistorySection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggestion History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        const SizedBox(height: 12),
        if (_suggestions.isEmpty)
          Text('No suggestions yet', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600]))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(suggestion.query, style: TextStyle(fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black)),
                          Text(suggestion.foodName, style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: Icon(suggestion.isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.delete, color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
  
  Widget _buildFooter(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(onPressed: () {}, child: const Text('Contact Support')),
              TextButton(onPressed: () {}, child: const Text('Terms')),
              TextButton(onPressed: () {}, child: const Text('Health Disclaimer')),
            ],
          ),
          const SizedBox(height: 8),
          Text('Consult healthcare professionals for medical advice', style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white54 : Colors.grey[500])),
        ],
      ),
    );
  }
}