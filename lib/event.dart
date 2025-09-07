import 'package:flutter/material.dart';
import 'app_state.dart' as app_state;

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
  late Animation<double> _fadeAnimation;

  // Convert admin events to user event format
  List<Event> _getEventsFromAppState(BuildContext context) {
    return app_state.AppState.instance.events.map((adminEvent) {
      return Event(
        id: adminEvent.id,
        title: adminEvent.name,
        sport: adminEvent.sportType,
        date: '${adminEvent.date.year}-${adminEvent.date.month.toString().padLeft(2, '0')}-${adminEvent.date.day.toString().padLeft(2, '0')}',
        time: adminEvent.time.format(context),
        location: adminEvent.location,
        gender: 'mixed', // Default to mixed since admin events don't have gender
        image: adminEvent.bannerPath ?? 'assets/images/default_event.png',
        registeredCount: 0, // Admin events don't track registration count
      );
    }).toList();
  }

  String _genderFilter = 'all';
  String _sportFilter = 'all';
  bool _showAll = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    // Listen to AppState changes to update when events are added
    app_state.AppState.instance.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    app_state.AppState.instance.removeListener(_onAppStateChanged);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    // Rebuild the widget when events change
    setState(() {});
  }

  List<Event> _getFilteredEvents(BuildContext context) {
    final events = _getEventsFromAppState(context);
    return events.where((event) {
      final genderMatch = _genderFilter == 'all' ||
          event.gender == _genderFilter ||
          event.gender == 'mixed';
      final sportMatch = _sportFilter == 'all' || event.sport == _sportFilter;
      return genderMatch && sportMatch;
    }).toList();
  }

  List<Event> _getDisplayedEvents(BuildContext context) {
    final filtered = _getFilteredEvents(context);
    if (_showAll || filtered.length <= 3) {
      return filtered;
    }
    return filtered.take(3).toList();
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

  void _shareEvent(Event event) {
    final text = '${event.title ?? 'Event'}\n'
        'Sport: ${event.sport ?? 'Sport'}\n'
        'Date: ${event.date ?? 'N/A'} at ${event.time ?? 'N/A'}\n'
        'Location: ${event.location ?? 'N/A'}\n'
        'Join us for this amazing event!';

    // Share functionality removed - package not available
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality not available'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildFilterBar(),
              _buildSwipeableEventCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGenderDropdown(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSportDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildSeeAllButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Filter by Gender',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.people),
      ),
      value: _genderFilter,
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Genders')),
        DropdownMenuItem(value: 'male', child: Text('Male')),
        DropdownMenuItem(value: 'female', child: Text('Female')),
        DropdownMenuItem(value: 'mixed', child: Text('Mixed')),
      ],
      onChanged: (value) {
        setState(() {
          _genderFilter = value!;
          _animationController.reset();
          _animationController.forward();
        });
      },
    );
  }

  Widget _buildSportDropdown() {
    final sports = ['all', 'Running', 'Basketball', 'Soccer', 'Tennis', 'Swimming'];
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Filter by Sport',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.sports),
      ),
      value: _sportFilter,
      items: sports.map((sport) {
        return DropdownMenuItem(
          value: sport,
          child: Text(sport == 'all' ? 'All Sports' : sport),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _sportFilter = value!;
          _animationController.reset();
          _animationController.forward();
        });
      },
    );
  }

  Widget _buildSwipeableEventCards() {
    final events = _getDisplayedEvents(context);
    if (events.isEmpty) {
    return Flexible(
      child: Center(
        child: Text(
          'No events match your filters',
          style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        ),
      ),
    );
    }

    // If showing all events, use ListView for single page display
    if (_showAll) {
      return Flexible(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AnimatedEventCard(
                event: events[index],
                onRegister: () => _showRegistrationModal(events[index]),
                onShare: () => _shareEvent(events[index]),
              ),
            );
          },
        ),
      );
    }

    // Default swipeable view for limited events
    return Flexible(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: events.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = (_pageController.page ?? 0.0) - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              return Transform.scale(
                scale: Curves.easeOut.transform(value),
                child: AnimatedEventCard(
                  event: events[index],
                  onRegister: () => _showRegistrationModal(events[index]),
                  onShare: () => _shareEvent(events[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSeeAllButton() {
    if (_getFilteredEvents(context).length <= 3) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton.icon(
        key: ValueKey(_showAll),
        onPressed: () {
          setState(() {
            _showAll = !_showAll;
            if (!_showAll) {
              if (_pageController.hasClients) {
                _pageController.jumpToPage(0);
              }
              _currentPage = 0;
            }
          });
        },
        icon: Icon(_showAll ? Icons.expand_less : Icons.expand_more),
        label: Text(_showAll ? 'Show Less' : 'See All (${_getFilteredEvents(context).length})'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
}

class AnimatedEventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onRegister;
  final VoidCallback onShare;

  const AnimatedEventCard({
    super.key,
    required this.event,
    required this.onRegister,
    required this.onShare,
  });

  @override
  State<AnimatedEventCard> createState() => _AnimatedEventCardState();
}

class _AnimatedEventCardState extends State<AnimatedEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Widget _buildGenderBadge() {
    Color badgeColor;
    IconData badgeIcon;

    switch ((widget.event.gender ?? 'mixed').toLowerCase()) {
      case 'male':
        badgeColor = Colors.blue;
        badgeIcon = Icons.male;
        break;
      case 'female':
        badgeColor = Colors.pink;
        badgeIcon = Icons.female;
        break;
      case 'mixed':
        badgeColor = Colors.green;
        badgeIcon = Icons.group;
        break;
      default:
        badgeColor = Colors.grey;
        badgeIcon = Icons.group;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            widget.event.gender.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _hoverController.forward();
        setState(() => _isHovered = true);
      },
      onTapUp: (_) {
        _hoverController.reverse();
        setState(() => _isHovered = false);
      },
      onTapCancel: () {
        _hoverController.reverse();
        setState(() => _isHovered = false);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 450,
                child: Card(
                  elevation: _isHovered ? 12 : 8,
                  shadowColor: null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildCardContent(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageHeader() {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.sports,
            size: 80,
            color: Colors.white54,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _buildGenderBadge(),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.event.sport ?? 'Sport',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.title ?? 'Event',
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildInfoRow(Icons.calendar_today, '${widget.event.date ?? 'N/A'} at ${widget.event.time ?? 'N/A'}'),
          const SizedBox(height: 8.0),
          _buildInfoRow(Icons.location_on, widget.event.location ?? 'N/A'),
          const SizedBox(height: 8.0),
          _buildInfoRow(Icons.people, '${widget.event.registeredCount ?? 0} registered'),
          const SizedBox(height: 20.0),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.0, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.0,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onRegister,
            icon: const Icon(Icons.how_to_reg),
            label: const Text('Register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: const Icon(Icons.share),
            color: Theme.of(context).colorScheme.primary,
            onPressed: widget.onShare,
          ),
        ),
      ],
    );
  }
}

class RegistrationModal extends StatefulWidget {
  final Event event;

  const RegistrationModal({super.key, required this.event});

  @override
  State<RegistrationModal> createState() => _RegistrationModalState();
}

class _RegistrationModalState extends State<RegistrationModal> {
  final _formKey = GlobalKey<FormState>();
  final RegistrationForm _form = RegistrationForm();

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
                  const Expanded(
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
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.event.title ?? 'Event',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
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
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => _form.email = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      value: _form.gender,
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (value) => _form.gender = value!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _submitRegistration();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
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

  void _submitRegistration() {
    try {
      // Here you would typically send the registration data to your backend
      // Add null checks
      if (_form.name.isEmpty || _form.email.isEmpty || _form.phone.isEmpty || widget.event.title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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