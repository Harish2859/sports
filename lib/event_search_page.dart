import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'event.dart';

class EventSearchPage extends StatefulWidget {
  const EventSearchPage({super.key});

  @override
  State<EventSearchPage> createState() => _EventSearchPageState();
}

class _EventSearchPageState extends State<EventSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Event> _filteredEvents = [];
  List<Event> _allEvents = [];

  @override
  void initState() {
    super.initState();
    _allEvents = _getAllEvents();
    _filteredEvents = _allEvents;
  }

  List<Event> _getAllEvents() {
    return [
      Event(
        id: '1',
        title: 'National Swimming Championship',
        sport: 'Swimming',
        date: '2024-02-15',
        time: '09:00 AM',
        location: 'Olympic Aquatic Center',
        gender: 'mixed',
        image: 'assets/images/event 1.jpg',
        registeredCount: 45,
        description: 'Join the most prestigious swimming competition of the year.',
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
        description: 'Challenge yourself in our annual city marathon.',
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
        description: 'Competitive basketball tournament featuring teams from across the city.',
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
        description: 'Annual tennis championship open to intermediate and advanced players.',
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
        description: 'The ultimate football showdown featuring the top 8 teams.',
      ),
    ];
  }

  void _filterEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEvents = _allEvents;
      } else {
        _filteredEvents = _allEvents.where((event) {
          return event.title.toLowerCase().contains(query.toLowerCase()) ||
                 event.sport.toLowerCase().contains(query.toLowerCase()) ||
                 event.location.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        title: Text('Search Events'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterEvents,
              decoration: InputDecoration(
                hintText: 'Search by sport, event name, or location...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
            ),
          ),
          // Results
          Expanded(
            child: _filteredEvents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_filteredEvents[index], isDarkMode);
                    },
                  ),
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
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No events found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching for basketball, swimming, or football',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, bool isDarkMode) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Event Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  event.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.sports, color: Colors.grey[600]),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sport Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.sport,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Event Title
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Date and Location
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          event.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
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
              SizedBox(height: 16),
              // Event Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  event.image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.sports, size: 80, color: Colors.grey[600]),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Event Details
              _buildDetailRow(Icons.sports, 'Sport', event.sport),
              _buildDetailRow(Icons.calendar_today, 'Date', event.date),
              _buildDetailRow(Icons.access_time, 'Time', event.time),
              _buildDetailRow(Icons.location_on, 'Location', event.location),
              _buildDetailRow(Icons.people, 'Registered', '${event.registeredCount} participants'),
              SizedBox(height: 16),
              // Description
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                event.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16),
              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Registration for ${event.title} opened!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Register Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}