import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recommended_courses.dart';
import 'theme_provider.dart';

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
    return Container(
      decoration: themeProvider.isGamified
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1a237e), Color(0xFF000000)],
              ),
            )
          : null,
      child: Scaffold(
        backgroundColor: themeProvider.isGamified ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Discover Your Sports Journey',
            style: TextStyle(
              color: themeProvider.isGamified ? Colors.white : null,
            ),
          ),
          backgroundColor: themeProvider.isGamified ? Colors.transparent : Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
          foregroundColor: themeProvider.isGamified ? Colors.white : Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          elevation: 0,
        ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information
            _buildSection(
              'Personal Information',
              Icons.person,
              [
                TextFormField(
                  style: TextStyle(color: themeProvider.isGamified ? Colors.white : null),
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: themeProvider.isGamified ? Colors.white70 : null),
                    prefixIcon: Icon(Icons.location_on, color: themeProvider.isGamified ? Colors.white70 : null),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.isGamified ? Colors.white : Theme.of(context).primaryColor),
                    ),
                  ),
                  onSaved: (value) => location = value,
                ),
                const SizedBox(height: 16),
                Text(
                  'Age: $age',
                  style: TextStyle(
                    color: themeProvider.isGamified ? Colors.white : null,
                  ),
                ),
                Slider(
                  value: age.toDouble(),
                  min: 12,
                  max: 65,
                  divisions: 53,
                  activeColor: themeProvider.isGamified ? Colors.white : Theme.of(context).primaryColor,
                  inactiveColor: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : null,
                  onChanged: (value) => setState(() => age = value.round()),
                ),
                const SizedBox(height: 16),
                Text(
                  'Weight: ${weight.round()} kg',
                  style: TextStyle(
                    color: themeProvider.isGamified ? Colors.white : null,
                  ),
                ),
                Slider(
                  value: weight,
                  min: 30,
                  max: 150,
                  activeColor: themeProvider.isGamified ? Colors.white : Theme.of(context).primaryColor,
                  inactiveColor: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : null,
                  onChanged: (value) => setState(() => weight = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sports Capability
            _buildSection(
              'Sports Capability',
              Icons.sports,
              [
                DropdownButtonFormField<String>(
                  value: skillLevel,
                  style: TextStyle(color: themeProvider.isGamified ? Colors.white : null),
                  dropdownColor: themeProvider.isGamified ? Colors.black87 : null,
                  decoration: InputDecoration(
                    labelText: 'Skill Level',
                    labelStyle: TextStyle(color: themeProvider.isGamified ? Colors.white70 : null),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : Colors.grey),
                    ),
                  ),
                  items: skillLevels.map((level) => DropdownMenuItem(
                    value: level,
                    child: Text(level.toUpperCase()),
                  )).toList(),
                  onChanged: (value) => setState(() => skillLevel = value),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fitness Level: $fitnessLevel/10',
                  style: TextStyle(
                    color: themeProvider.isGamified ? Colors.white : null,
                  ),
                ),
                Slider(
                  value: fitnessLevel.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: themeProvider.isGamified ? Colors.white : Theme.of(context).primaryColor,
                  inactiveColor: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : null,
                  onChanged: (value) => setState(() => fitnessLevel = value.round()),
                ),
                const SizedBox(height: 16),
                Text(
                  'Weekly Availability: $weeklyAvailability hours',
                  style: TextStyle(
                    color: themeProvider.isGamified ? Colors.white : null,
                  ),
                ),
                Slider(
                  value: weeklyAvailability.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  activeColor: themeProvider.isGamified ? Colors.white : Theme.of(context).primaryColor,
                  inactiveColor: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : null,
                  onChanged: (value) => setState(() => weeklyAvailability = value.round()),
                ),
                const SizedBox(height: 16),
                Text(
                  'Favorite Sports:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isGamified ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sportsOptions.map((sport) => FilterChip(
                    label: Text(
                      sport,
                      style: TextStyle(
                        color: favoritesSports.contains(sport)
                            ? (themeProvider.isGamified ? Colors.black : Colors.white)
                            : (themeProvider.isGamified ? Colors.white : null),
                      ),
                    ),
                    selected: favoritesSports.contains(sport),
                    selectedColor: themeProvider.isGamified ? Colors.white : Theme.of(context).primaryColor,
                    backgroundColor: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : null,
                    checkmarkColor: themeProvider.isGamified ? Colors.black : Colors.white,
                    side: themeProvider.isGamified ? BorderSide(color: Colors.white.withOpacity(0.3)) : null,
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

            // Preferences
            _buildSection(
              'Preferences',
              Icons.settings,
              [
                DropdownButtonFormField<String>(
                  value: trainingType,
                  style: TextStyle(color: themeProvider.isGamified ? Colors.white : null),
                  dropdownColor: themeProvider.isGamified ? Colors.black87 : null,
                  decoration: InputDecoration(
                    labelText: 'Training Type',
                    labelStyle: TextStyle(color: themeProvider.isGamified ? Colors.white70 : null),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : Colors.grey),
                    ),
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
                  style: TextStyle(color: themeProvider.isGamified ? Colors.white : null),
                  dropdownColor: themeProvider.isGamified ? Colors.black87 : null,
                  decoration: InputDecoration(
                    labelText: 'Diet Preference',
                    labelStyle: TextStyle(color: themeProvider.isGamified ? Colors.white70 : null),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : Colors.grey),
                    ),
                  ),
                  items: dietPreferences.map((diet) => DropdownMenuItem(
                    value: diet,
                    child: Text(diet == 'none' ? 'No Preference' : diet.toUpperCase()),
                  )).toList(),
                  onChanged: (value) => setState(() => dietPreference = value),
                ),
                const SizedBox(height: 16),
                Text(
                  'Budget: \$${budget}/month',
                  style: TextStyle(
                    color: themeProvider.isGamified ? Colors.white : null,
                  ),
                ),
                Slider(
                  value: budget.toDouble(),
                  min: 50,
                  max: 500,
                  divisions: 45,
                  activeColor: themeProvider.isGamified ? Colors.white : Theme.of(context).primaryColor,
                  inactiveColor: themeProvider.isGamified ? Colors.white.withOpacity(0.3) : null,
                  onChanged: (value) => setState(() => budget = value.round()),
                ),
                const SizedBox(height: 16),
                Text(
                  'Training Environment:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isGamified ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['indoor', 'outdoor', 'both'].map((option) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          option.toUpperCase(),
                          style: TextStyle(
                            color: indoorOutdoor == option
                                ? (themeProvider.isGamified ? Colors.black : Colors.white)
                                : (themeProvider.isGamified ? Colors.white : null),
                          ),
                        ),
                        selected: indoorOutdoor == option,
                        selectedColor: themeProvider.isGamified ? Colors.white : Theme.of(context).primaryColor,
                        backgroundColor: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : null,
                        side: themeProvider.isGamified ? BorderSide(color: Colors.white.withOpacity(0.3)) : null,
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

            // Action Buttons
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
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
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
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: themeProvider.isGamified ? Border.all(color: Colors.white.withOpacity(0.2)) : null,
        boxShadow: themeProvider.isGamified ? null : [
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
              Icon(icon, color: themeProvider.isGamified ? Colors.white : Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Provider.of<ThemeProvider>(context).isGamified ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
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