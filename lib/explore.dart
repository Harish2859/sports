import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recommended_courses.dart';
import 'theme_provider.dart';
import 'app_state.dart';


class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _formKey = GlobalKey<FormState>();

  // State variables from your original code
  String? location;
  int age = 25;
  double weight = 70;
  String? skillLevel = 'beginner';
  int fitnessLevel = 5;
  int weeklyAvailability = 5;
  List<String> favoritesSports = ['Football', 'Tennis'];
  String? trainingType = 'group';
  String? dietPreference = 'none';
  String? indoorOutdoor = 'both';
  int budget = 150;

  final List<String> sportsOptions = [
    'Football', 'Basketball', 'Tennis', 'Swimming', 'Running', 'Cycling',
    'Boxing', 'Yoga', 'Weightlifting', 'Martial Arts', 'Cricket', 'Baseball'
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // A slightly off-white background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Discover Your Sports Journey',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [

                  // --- Section 1: Personal Information ---
                  _buildSectionTitle(Icons.person_outline, 'Personal Details'),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: "Malayambakkam, Tamil Nadu",
                    decoration: _inputDecoration('Location', Icons.location_on_outlined),
                    onSaved: (value) => location = value,
                  ),
                  const SizedBox(height: 20),
                  _buildSliderRow(
                    label: 'Age',
                    value: age.toString(),
                    slider: Slider(
                      value: age.toDouble(),
                      min: 12,
                      max: 65,
                      divisions: 53,
                      onChanged: (value) => setState(() => age = value.round()),
                    ),
                  ),
                  _buildSliderRow(
                    label: 'Weight',
                    value: '${weight.round()} kg',
                    slider: Slider(
                      value: weight,
                      min: 30,
                      max: 150,
                      onChanged: (value) => setState(() => weight = value),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Section 2: Sports Capability ---
                  _buildSectionTitle(Icons.fitness_center_outlined, 'Fitness & Skills'),
                  const SizedBox(height: 16),
                  _buildLabel('Skill Level'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['beginner', 'intermediate', 'advanced'].map((level) => 
                      _buildChoiceChip(
                        label: level,
                        isSelected: skillLevel == level,
                        onTap: () => setState(() => skillLevel = level),
                      )
                    ).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildSliderRow(
                    label: 'Fitness Level',
                    value: '$fitnessLevel / 10',
                    slider: Slider(
                      value: fitnessLevel.toDouble(),
                      min: 1, max: 10, divisions: 9,
                      onChanged: (value) => setState(() => fitnessLevel = value.round()),
                    ),
                  ),
                  _buildSliderRow(
                    label: 'Weekly Availability',
                    value: '$weeklyAvailability hours',
                    slider: Slider(
                      value: weeklyAvailability.toDouble(),
                      min: 1, max: 20, divisions: 19,
                      onChanged: (value) => setState(() => weeklyAvailability = value.round()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Favorite Sports'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: sportsOptions.map((sport) => _buildFilterChip(
                      label: sport,
                      isSelected: favoritesSports.contains(sport),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            favoritesSports.add(sport);
                          } else {
                            favoritesSports.remove(sport);
                          }
                        });
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 32),

                  // --- Section 3: Preferences ---
                  _buildSectionTitle(Icons.tune_outlined, 'Preferences'),
                  const SizedBox(height: 16),
                   _buildLabel('Preferred Training Type'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['individual', 'group', 'team'].map((type) => 
                      _buildChoiceChip(
                        label: type,
                        isSelected: trainingType == type,
                        onTap: () => setState(() => trainingType = type),
                      )
                    ).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildSliderRow(
                    label: 'Monthly Budget',
                    value: '\$${budget}',
                    slider: Slider(
                      value: budget.toDouble(),
                      min: 50, max: 500, divisions: 45,
                      onChanged: (value) => setState(() => budget = value.round()),
                    ),
                  ),
                ],
              ),
            ),

            // --- Sticky Bottom Action Bar ---
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // --- Reusable UI Helper Widgets ---

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String value,
    required Slider slider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel(label),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: slider,
        )
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Text(
            label[0].toUpperCase() + label.substring(1),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: Colors.blueAccent,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _navigateToRecommendedCourses();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Find My Course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {
                _formKey.currentState!.save();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences saved!')),
                );
              },
              child: const Text('Save', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  void _navigateToRecommendedCourses() {
    final userPreferences = {
      'location': location,
      'age': age,
      'weight': weight,
      'skillLevel': skillLevel,
      'fitnessLevel': fitnessLevel,
      'weeklyAvailability': weeklyAvailability,
      'favoritesSports': favoritesSports,
      'trainingType': trainingType,
      'dietPreference': dietPreference,
      'indoorOutdoor': indoorOutdoor,
      'budget': budget,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendedCoursesPage(userPreferences: userPreferences),
      ),
    );
  }
}