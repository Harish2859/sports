import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'app_state.dart' as app_state;
import 'theme_provider.dart';

class Event {
  final String id;
  final String title;
  final String sport;
  final String date;
  final String time;
  final String location;
  final String gender;
  final String image;
  final int registeredCount;
  final String? requiredCertificate;
  final String description;

  Event({
    required this.id,
    required this.title,
    required this.sport,
    required this.date,
    required this.time,
    required this.location,
    required this.gender,
    required this.image,
    required this.registeredCount,
    this.requiredCertificate,
    this.description = '',
  });
}

class RegistrationForm {
  String name;
  String email;
  String phone;
  String gender;
  int age;
  String experienceLevel;
  String preferredPosition;
  String emergencyContactName;
  String emergencyContactPhone;
  String medicalConditions;
  String tshirtSize;
  String dietaryRestrictions;

  RegistrationForm({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.gender = 'male',
    this.age = 18,
    this.experienceLevel = 'beginner',
    this.preferredPosition = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.medicalConditions = '',
    this.tshirtSize = 'M',
    this.dietaryRestrictions = '',
  });
}

class SportsEventPage extends StatefulWidget {
  const SportsEventPage({super.key});

  @override
  State<SportsEventPage> createState() => _SportsEventPageState();
}

class _SportsEventPageState extends State<SportsEventPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _swipeAnimationController;
  late Animation<double> _swipeAnimation;
  bool _isAnimating = false;

  // Convert admin events to user event format
  List<Event> _getEventsFromAppState(BuildContext context) {
    final adminEvents = app_state.AppState.instance.events;
    
    if (adminEvents.isNotEmpty) {
      return adminEvents.map((adminEvent) {
        return Event(
          id: adminEvent.id,
          title: adminEvent.name,
          sport: adminEvent.sportType,
          date: '${adminEvent.date.year}-${adminEvent.date.month.toString().padLeft(2, '0')}-${adminEvent.date.day.toString().padLeft(2, '0')}',
          time: adminEvent.time.format(context),
          location: adminEvent.location,
          gender: 'mixed',
          image: adminEvent.bannerPath ?? 'assets/images/default_event.png',
          registeredCount: 0,
          requiredCertificate: adminEvent.requiredCertificate,
          description: adminEvent.description ?? 'Join us for this exciting ${adminEvent.sportType} event at ${adminEvent.location}. Whether you\'re a beginner or experienced athlete, this event welcomes all skill levels. Come and be part of an amazing sporting experience with fellow enthusiasts!',
        );
      }).toList();
    }
    
    // Return prebuilt events if no admin events exist
    return [
      Event(
        id: '1',
        title: 'National Swimming event',
        sport: 'Swimming',
        date: '2024-02-15',
        time: '09:00 AM',
        location: 'Olympic Aquatic Center',
        gender: 'mixed',
        image: 'assets/images/event 1.jpg',
        registeredCount: 45,
        description: 'Join the most prestigious swimming competition of the year. Open to all skill levels with separate categories for beginners and professionals. Experience world-class facilities and compete with the best swimmers .',
      ),
      Event(
        id: '2',
        title: 'City Marathon 2024',
        sport: 'Running',
        date: '2024-03-10',
        time: '06:00 AM',
        location: 'Central Park',
        gender: 'mixed',
        image: 'assets/images/event 2.jpg',
        registeredCount: 120,
        description: 'Challenge yourself in our annual city marathon. Choose from 5K, 10K, or full marathon distances. Professional timing, medical support, and refreshment stations available throughout the course.',
      ),
      Event(
        id: '3',
        title: 'Basketball Tournament',
        sport: 'Basketball',
        date: '2024-02-28',
        time: '02:00 PM',
        location: 'Sports Complex Arena',
        gender: 'mixed',
        image: 'assets/images/event 3.jpg',
        registeredCount: 32,
        description: 'Competitive basketball tournament featuring teams from across the city. 3v3 and 5v5 formats available. Prizes for winners and participation certificates for all players.',
      ),
      Event(
        id: '4',
        title: 'Tennis Open Championship',
        sport: 'Tennis',
        date: '2024-03-05',
        time: '10:00 AM',
        location: 'Tennis Club Courts',
        gender: 'mixed',
        image: 'assets/images/event 4.jpg',
        registeredCount: 28,
        requiredCertificate: 'Tennis Proficiency Certificate',
        description: 'Annual tennis championship open to intermediate and advanced players. Singles and doubles categories available. Professional umpires and high-quality courts ensure fair competition.',
      ),
      Event(
        id: '5',
        title: 'Football League Finals',
        sport: 'Football',
        date: '2024-03-20',
        time: '04:00 PM',
        location: 'Stadium Ground',
        gender: 'mixed',
        image: 'assets/images/event 5.jpg',
        registeredCount: 88,
        description: 'The ultimate football showdown featuring the top 8 teams from our seasonal league. Witness intense matches, skilled gameplay, and crown the champion team of the year.',
      ),
    ];
  }

  int _currentPage = 0;
  int _targetPage = 0;

  @override
  void initState() {
    super.initState();
    _targetPage = _currentPage;
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _swipeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _swipeAnimationController, curve: Curves.easeInOut),
    );

    app_state.AppState.instance.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    app_state.AppState.instance.removeListener(_onAppStateChanged);
    _pageController.dispose();
    _animationController.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    setState(() {});
  }

  void _showRegistrationModal(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RegistrationModal(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsFromAppState(context);
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
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: events.isEmpty
                    ? _buildEmptyState()
                    : _buildSwipeableCards(events),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selectedSport = 'All Sports';

  Widget _buildTopBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: themeProvider.isGamified ? Colors.white.withOpacity(0.1) : Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: themeProvider.isGamified ? Colors.white.withOpacity(0.2) : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedSport,
              underline: const SizedBox(),
              dropdownColor: themeProvider.isGamified ? Colors.black87 : Colors.white,
              items: ['All Sports', 'Swimming', 'Running', 'Basketball', 'Tennis', 'Football']
                  .map((sport) => DropdownMenuItem(
                        value: sport,
                        child: Text(
                          sport,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isGamified ? Colors.white : Colors.black87,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSport = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: themeProvider.isGamified ? Colors.white30 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No events available',
            style: TextStyle(
              fontSize: 18,
              color: themeProvider.isGamified ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableCards(List<Event> events) {
    return Column(
      children: [
        // Top Section - Name and Description (Full Width)
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_animationController.value * 50, 0),
              child: Opacity(
                opacity: 1 - _animationController.value,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildTopSection(events[_currentPage]),
                ),
              ),
            );
          },
        ),
        // Middle Row - Split into Left and Right (Equal)
        Expanded(
          child: Row(
            children: [
              // Left Section - Event Details (50%)
              Expanded(
                flex: 50,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(-_animationController.value * 30, 0),
                      child: Opacity(
                        opacity: 1 - _animationController.value,
                        child: Container(
                          margin: const EdgeInsets.only(left: 16, right: 8, top: 60),
                          height: 200,
                          child: _buildEventDetailsSection(events[_currentPage]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Right Section - Image Stack (50%)
              Expanded(
                flex: 50,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_animationController.value * 30, 0),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        height: 200,
                        child: _buildCardStack(events),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Bottom Section - Register Button (Full Width)
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 - (_animationController.value * 0.1),
              child: Opacity(
                opacity: 1 - _animationController.value,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => _showRegistrationModal(events[_currentPage]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Page Indicator
        _buildPageIndicator(events.length),
      ],
    );
  }

  Widget _buildTopSection(Event event) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sport Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: themeProvider.isGamified ? Colors.white.withOpacity(0.2) : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            event.sport,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.isGamified ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Event Title
        SizedBox(
          width: double.infinity,
          child: Text(
            event.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.isGamified ? Colors.white : Colors.black87,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
        const SizedBox(height: 12),
        // Event Description
        SizedBox(
          width: double.infinity,
          child: Text(
            event.description,
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isGamified ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetailsSection(Event event) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.isGamified ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow(Icons.calendar_today, 'Date', event.date, themeProvider),
        const SizedBox(height: 12),
        _buildDetailRow(Icons.access_time, 'Time', event.time, themeProvider),
        const SizedBox(height: 12),
        _buildDetailRow(Icons.location_on, 'Location', event.location, themeProvider),
      ],
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value, ThemeProvider themeProvider) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: themeProvider.isGamified ? Colors.white70 : Colors.black54,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: themeProvider.isGamified ? Colors.white70 : Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isGamified ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCardStack(List<Event> events) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!_isAnimating && details.delta.dx < -10) {
          _nextCard(events);
        }
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Current card (tall)
            Container(
              width: 120,
              height: 170,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildImageCard(events[_currentPage]),
            ),
            // Upcoming card (short)
            Container(
              width: 80,
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildImageCard(events[(_currentPage + 1) % events.length]),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageCard(Event event) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          event.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
        ),
      ),
    );
  }
  
  void _nextCard(List<Event> events) {
    if (!_isAnimating) {
      _isAnimating = true;
      setState(() {
        _currentPage = (_currentPage + 1) % events.length;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _isAnimating = false;
      });
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/indian_emblem.png', // You can replace this with your emblem asset
          height: 120,
          width: 120,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.sports,
            size: 80,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int itemCount) {
    if (itemCount <= 1) return const SizedBox.shrink();
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(itemCount, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? (themeProvider.isGamified ? Colors.white : Colors.black)
                  : (themeProvider.isGamified ? Colors.white30 : Colors.grey),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

// Registration Modal
class RegistrationModal extends StatefulWidget {
  final Event event;

  const RegistrationModal({super.key, required this.event});

  @override
  State<RegistrationModal> createState() => _RegistrationModalState();
}

class _RegistrationModalState extends State<RegistrationModal> {
  final _formKey = GlobalKey<FormState>();
  final RegistrationForm _form = RegistrationForm();
  String? _certificatePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Register for Event',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                widget.event.title,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _form.name = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => _form.email = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) => _form.phone = value!,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      value: _form.gender,
                      items: [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (value) => _form.gender = value!,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _form.age.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 16 || age > 100) {
                          return 'Please enter a valid age (16-100)';
                        }
                        return null;
                      },
                      onSaved: (value) => _form.age = int.parse(value!),
                    ),
                  ),
                ],
              ),
              if (widget.event.requiredCertificate != null) SizedBox(height: 16),
              if (widget.event.requiredCertificate != null) _buildCertificateUpload(),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.event.requiredCertificate != null && _certificatePath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select the required certificate'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      _formKey.currentState!.save();
                      _submitRegistration();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Complete Registration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select ${widget.event.requiredCertificate}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickCertificate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Column(
              children: [
                Icon(
                  _certificatePath != null ? Icons.check_circle : Icons.upload_file,
                  size: 40,
                  color: _certificatePath != null ? Colors.green : Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  _certificatePath != null ? 'Certificate selected' : 'Tap to select certificate',
                  style: TextStyle(
                    color: _certificatePath != null ? Colors.green : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_certificatePath != null)
                  Text(
                    'ID: $_certificatePath',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _pickCertificate() async {
    final dummyCertificates = [
      {
        'id': 'CERT-JAV-001',
        'courseTitle': 'Javelin Certificate',
        'completionDate': DateTime.now().subtract(Duration(days: 30)),
        'issuer': 'Athletics Federation',
      },
      {
        'id': 'CERT-ATH-002', 
        'courseTitle': 'Athletics Certificate',
        'completionDate': DateTime.now().subtract(Duration(days: 60)),
        'issuer': 'Sports Authority',
      },
      {
        'id': 'CERT-SWM-003',
        'courseTitle': 'Swimming Certificate',
        'completionDate': DateTime.now().subtract(Duration(days: 90)),
        'issuer': 'Aquatic Sports Board',
      },
      {
        'id': 'CERT-GEN-004',
        'courseTitle': 'General Sports Certificate',
        'completionDate': DateTime.now().subtract(Duration(days: 120)),
        'issuer': 'National Sports Council',
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Certificate'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dummyCertificates.length,
              itemBuilder: (context, index) {
                final cert = dummyCertificates[index];
                return ListTile(
                  leading: Icon(Icons.verified, color: Colors.green),
                  title: Text(cert['courseTitle'] as String),
                  subtitle: Text('ID: ${cert['id']}'),
                  onTap: () {
                    setState(() {
                      _certificatePath = cert['id'] as String;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected: ${cert['courseTitle']}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _submitRegistration() {
    try {
      if (_form.name.isEmpty || _form.email.isEmpty || _form.phone.isEmpty || widget.event.title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully registered for ${widget.event.title}!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}