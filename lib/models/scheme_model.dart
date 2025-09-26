class Scheme {
  final String title;
  final String organization;
  final String description;
  final List<String> eligibility;
  final String type;
  final String location;
  final String sport;
  final int minAge;
  final int maxAge;
  final double latitude;
  final double longitude;
  final bool isForParaSport;
  final String programType;
  final List<String> facilities;
  final DateTime applicationDeadline;

  Scheme({
    required this.title,
    required this.organization,
    required this.description,
    required this.eligibility,
    required this.type,
    required this.location,
    required this.sport,
    required this.minAge,
    required this.maxAge,
    required this.latitude,
    required this.longitude,
    required this.isForParaSport,
    required this.programType,
    required this.facilities,
    required this.applicationDeadline,
  });
}