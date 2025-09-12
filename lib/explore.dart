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

  String? location;
  int age = 18;
  double weight = 70;
  String? skillLevel = 'beginner';
  int fitnessLevel = 5;
  int weeklyAvailability = 3;
  List<String> favoritesSports = [];
  String? trainingType = 'group';
  String? dietPreference = 'none';
  String? indoorOutdoor = 'both';
  int budget = 100;

  final List<String> sportsOptions = [
    'Football', 'Basketball', 'Tennis', 'Swimming', 'Running', 'Cycling',
    'Boxing', 'Yoga', 'Weightlifting', 'Martial Arts', 'Cricket', 'Baseball'
  ];

  final List<String> skillLevels = ['beginner', 'intermediate', 'advanced'];
  final List<String> trainingTypes = ['individual', 'group', 'team'];
  final List<String> dietPreferences = ['none', 'vegetarian', 'vegan', 'keto'];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Discover Your Sports Journey'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              'Personal Information',
              Icons.person,
              [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => location = value,
                ),
                const SizedBox(height: 16),
                Text('Age: $age'),
                Slider(
                  value: age.toDouble(),
                  min: 12,
                  max: 65,
                  divisions: 53,
                  onChanged: (value) => setState(() => age = value.round()),
                ),
                const SizedBox(height: 16),
                Text('Weight: ${weight.round()} kg'),
                Slider(
                  value: weight,
                  min: 30,
                  max: 150,
                  onChanged: (value) => setState(() => weight = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Sports Capability',
              Icons.sports,
              [
                DropdownButtonFormField<String>(
                  value: skillLevel,
                  decoration: InputDecoration(
                    labelText: 'Skill Level',
                    border: OutlineInputBorder(),
                  ),
                  items: skillLevels.map((level) => DropdownMenuItem(
                    value: level,
                    child: Text(level.toUpperCase()),
                  )).toList(),
                  onChanged: (value) => setState(() => skillLevel = value),
                ),
                const SizedBox(height: 16),
                Text('Fitness Level: $fitnessLevel/10'),
                Slider(
                  value: fitnessLevel.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) => setState(() => fitnessLevel = value.round()),
                ),
                const SizedBox(height: 16),
                Text('Weekly Availability: $weeklyAvailability hours'),
                Slider(
                  value: weeklyAvailability.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  onChanged: (value) => setState(() => weeklyAvailability = value.round()),
                ),
                const SizedBox(height: 16),
                Text('Favorite Sports:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sportsOptions.map((sport) => FilterChip(
                    label: Text(sport),
                    selected: favoritesSports.contains(sport),
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
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Preferences',
              Icons.settings,
              [
                DropdownButtonFormField<String>(
                  value: trainingType,
                  decoration: InputDecoration(
                    labelText: 'Training Type',
                    border: OutlineInputBorder(),
                  ),
                  items: trainingTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  )).toList(),
                  onChanged: (value) => setState(() => trainingType = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: dietPreference,
                  decoration: InputDecoration(
                    labelText: 'Diet Preference',
                    border: OutlineInputBorder(),
                  ),
                  items: dietPreferences.map((diet) => DropdownMenuItem(
                    value: diet,
                    child: Text(diet == 'none' ? 'No Preference' : diet.toUpperCase()),
                  )).toList(),
                  onChanged: (value) => setState(() => dietPreference = value),
                ),
                const SizedBox(height: 16),
                Text('Budget: \$${budget}/month'),
                Slider(
                  value: budget.toDouble(),
                  min: 50,
                  max: 500,
                  divisions: 45,
                  onChanged: (value) => setState(() => budget = value.round()),
                ),
                const SizedBox(height: 16),
                Text('Training Environment:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: ['indoor', 'outdoor', 'both'].map((option) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(option.toUpperCase()),
                        selected: indoorOutdoor == option,
                        onSelected: (selected) {
                          if (selected) setState(() => indoorOutdoor = option);
                        },
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
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
                    ),
                    child: const Text('Find My Course'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _formKey.currentState!.save();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preferences saved!')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save & Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
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