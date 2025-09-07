import 'package:flutter/material.dart';
import 'notification_manager.dart';
import 'app_state.dart';

class AdminEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EventsListScreen();
  }
}

// Event Model
class Event {
  final String id;
  final String name;
  final DateTime date;
  final TimeOfDay time;
  final String location;
  final String sportType;
  final String description;
  final String? bannerPath;
  final EventStatus status;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.sportType,
    required this.description,
    this.bannerPath,
    required this.status,
  });

  Event copyWith({
    String? id,
    String? name,
    DateTime? date,
    TimeOfDay? time,
    String? location,
    String? sportType,
    String? description,
    String? bannerPath,
    EventStatus? status,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      sportType: sportType ?? this.sportType,
      description: description ?? this.description,
      bannerPath: bannerPath ?? this.bannerPath,
      status: status ?? this.status,
    );
  }
}

enum EventStatus { upcoming, ongoing, completed }

// Add Event Form Screen
class AddEventScreen extends StatefulWidget {
  final Event? event;

  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedSportType;
  String? _bannerPath;
  bool _isLoading = false;

  final List<String> _sportTypes = [
    'Football', 'Cricket', 'Athletics', 'Basketball', 'Tennis',
    'Swimming', 'Volleyball', 'Badminton', 'Table Tennis', 'Hockey',
  ];

  final Map<String, IconData> _sportIcons = {
    'Football': Icons.sports_soccer,
    'Cricket': Icons.sports_cricket,
    'Athletics': Icons.directions_run,
    'Basketball': Icons.sports_basketball,
    'Tennis': Icons.sports_tennis,
    'Swimming': Icons.pool,
    'Volleyball': Icons.sports_volleyball,
    'Badminton': Icons.sports_tennis,
    'Table Tennis': Icons.sports_tennis,
    'Hockey': Icons.sports_hockey,
  };

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _populateFormWithExistingData();
    }
  }

  void _populateFormWithExistingData() {
    final event = widget.event!;
    _nameController.text = event.name;
    _locationController.text = event.location;
    _descriptionController.text = event.description;
    _selectedDate = event.date;
    _selectedTime = event.time;
    _selectedSportType = event.sportType;
    _bannerPath = event.bannerPath;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Event' : 'Add New Event',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Event Details'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Event Name',
                hint: 'Enter event name',
                icon: Icons.event,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(),
              const SizedBox(height: 20),
              _buildSectionTitle('Schedule'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDatePicker()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePicker()),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Venue'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Location / Venue',
                hint: 'Enter venue location',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter venue location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Description'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Event Description',
                hint: 'Enter event details and notes',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Event Banner (Optional)'),
              const SizedBox(height: 16),
              _buildImageUpload(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSaveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Event' : 'Create Event',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedSportType,
      decoration: InputDecoration(
        labelText: 'Sport Type',
        prefixIcon: Icon(
          _selectedSportType != null ? _sportIcons[_selectedSportType!] : Icons.sports,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: _sportTypes.map((sport) {
        return DropdownMenuItem<String>(
          value: sport,
          child: Row(
            children: [
              Icon(_sportIcons[sport], size: 20, color: const Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Text(sport),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSportType = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a sport type';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select Date',
                    style: TextStyle(
                      color: _selectedDate != null 
                          ? Theme.of(context).textTheme.titleLarge?.color 
                          : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                    style: TextStyle(
                      color: _selectedTime != null 
                          ? Theme.of(context).textTheme.titleLarge?.color 
                          : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: _bannerPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _bannerPath = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cloud_upload,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Event Banner',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'JPG, PNG up to 5MB',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _pickImage() async {
    setState(() {
      _bannerPath = 'assets/sample_banner.jpg';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image selected successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleSaveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final isEditing = widget.event != null;

    if (isEditing) {
      final updatedEvent = widget.event!.copyWith(
        name: _nameController.text,
        date: _selectedDate!,
        time: _selectedTime!,
        location: _locationController.text,
        sportType: _selectedSportType!,
        description: _descriptionController.text,
        bannerPath: _bannerPath,
      );
      AppState.instance.updateEvent(updatedEvent);
    } else {
      final newEvent = Event(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        date: _selectedDate!,
        time: _selectedTime!,
        location: _locationController.text,
        sportType: _selectedSportType!,
        description: _descriptionController.text,
        bannerPath: _bannerPath,
        status: EventStatus.upcoming,
      );
      AppState.instance.addEvent(newEvent);
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing ? 'Event updated successfully!' : 'Event created successfully!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    if (!isEditing) {
      final eventDate = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
      NotificationManager.instance.addEventNotification(
        _nameController.text,
        eventDate,
      );
    }

    Navigator.pop(context, 'refresh');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// Events List Screen
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSportFilter = 'All';
  String _selectedStatusFilter = 'All';

  final List<String> _sportFilters = ['All', 'Football', 'Cricket', 'Athletics', 'Basketball', 'Tennis'];
  final List<String> _statusFilters = ['All', 'Upcoming', 'Ongoing', 'Completed'];

  final Map<String, IconData> _sportIcons = {
    'Football': Icons.sports_soccer,
    'Cricket': Icons.sports_cricket,
    'Athletics': Icons.directions_run,
    'Basketball': Icons.sports_basketball,
    'Tennis': Icons.sports_tennis,
    'Swimming': Icons.pool,
  };

  List<Event> get _filteredEvents {
    return AppState.instance.events.where((event) {
      final matchesSearch = event.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                          event.location.toLowerCase().contains(_searchController.text.toLowerCase());

      final matchesSport = _selectedSportFilter == 'All' || event.sportType == _selectedSportFilter;

      final matchesStatus = _selectedStatusFilter == 'All' ||
                           event.status.toString().split('.').last.toLowerCase() == _selectedStatusFilter.toLowerCase();

      return matchesSearch && matchesSport && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Coach Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Findrly - Empowering Talent',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.group, color: Theme.of(context).primaryColor),
              title: const Text('Manage Athletes'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
              title: const Text('Training Schedule'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assessment, color: Theme.of(context).primaryColor),
              title: const Text('Performance Analytics'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: Theme.of(context).primaryColor),
              title: const Text('Competitions'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.fitness_center, color: Theme.of(context).primaryColor),
              title: const Text('Equipment Management'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: Theme.of(context).primaryColor),
              title: const Text('Health & Safety'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Theme.of(context).primaryColor),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Findrly',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Events Management',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _navigateToAddEvent(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _filteredEvents.isEmpty
                ? _buildEmptyState()
                : _buildEventsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEvent(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFilterDropdown('Sport', _selectedSportFilter, _sportFilters, (value) {
                setState(() {
                  _selectedSportFilter = value!;
                });
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildFilterDropdown('Status', _selectedStatusFilter, _statusFilters, (value) {
                setState(() {
                  _selectedStatusFilter = value!;
                });
              })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    final statusColor = _getStatusColor(event.status);
    final statusText = _getStatusText(event.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _sportIcons[event.sportType] ?? Icons.sports,
                  color: const Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.sportType,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                '${event.date.day}/${event.date.month}/${event.date.year} at ${event.time.format(context)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.description.length > 100 
                ? '${event.description.substring(0, 100)}...'
                : event.description,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editEvent(event),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteEvent(event),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.event_note,
              size: 40,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Events Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first event to get started',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddEvent(),
            icon: const Icon(Icons.add),
            label: const Text('Add Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return const Color(0xFF2563EB);
      case EventStatus.ongoing:
        return const Color(0xFF059669);
      case EventStatus.completed:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
    }
  }

  void _navigateToAddEvent([Event? event]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(event: event),
      ),
    );
    
    if (result == 'refresh') {
      setState(() {});
    }
  }

  void _editEvent(Event event) {
    _navigateToAddEvent(event);
  }

  void _deleteEvent(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Event',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${event.name}"?',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _confirmDeleteEvent(event);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteEvent(Event event) {
    AppState.instance.deleteEvent(event.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event "${event.name}" deleted successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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