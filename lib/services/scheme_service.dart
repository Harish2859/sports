import '../models/scheme_model.dart';

class SchemeService {
  static final List<Scheme> _allSchemes = [
    Scheme(
      title: 'Elite Cricket Academy Program',
      organization: 'Tamil Nadu Cricket Association',
      description: 'Comprehensive cricket training program for aspiring young cricketers with professional coaching and modern facilities.',
      eligibility: ['Age: 12-18 years', 'Basic cricket knowledge required', 'Physical fitness assessment'],
      type: 'Free Coaching',
      location: 'Chennai, Tamil Nadu',
      sport: 'Cricket',
      minAge: 12,
      maxAge: 18,
      latitude: 13.0827,
      longitude: 80.2707,
      isForParaSport: false,
      programType: 'Day Program',
      facilities: ['Professional Coaching', 'Modern Equipment', 'Fitness Center', 'Video Analysis'],
      applicationDeadline: DateTime(2025, 6, 30),
    ),
    Scheme(
      title: 'Paralympic Swimming Excellence',
      organization: 'Karnataka Paralympic Committee',
      description: 'Specialized swimming program designed for athletes with disabilities to compete at national and international levels.',
      eligibility: ['Age: 14-25 years', 'Disability certificate required', 'Basic swimming ability'],
      type: 'Scholarship',
      location: 'Bengaluru, Karnataka',
      sport: 'Swimming',
      minAge: 14,
      maxAge: 25,
      latitude: 12.9716,
      longitude: 77.5946,
      isForParaSport: true,
      programType: 'Residential',
      facilities: ['Olympic Pool', 'Physiotherapy', 'Specialized Equipment', 'Medical Support'],
      applicationDeadline: DateTime(2025, 8, 15),
    ),
    Scheme(
      title: 'Football Grassroots Development',
      organization: 'All India Football Federation',
      description: 'Community-based football program focusing on skill development and talent identification at the grassroots level.',
      eligibility: ['Age: 8-16 years', 'No prior experience needed', 'Parental consent'],
      type: 'Free Coaching',
      location: 'Goa, Goa',
      sport: 'Football',
      minAge: 8,
      maxAge: 16,
      latitude: 15.2993,
      longitude: 74.1240,
      isForParaSport: false,
      programType: 'Weekend Camp',
      facilities: ['FIFA Standard Pitch', 'Youth Coaching', 'Sports Psychology', 'Nutrition Guidance'],
      applicationDeadline: DateTime(2025, 9, 30),
    ),
    Scheme(
      title: 'Archery Excellence Initiative',
      organization: 'Assam Archery Association',
      description: 'Traditional and modern archery training program promoting the rich archery heritage of Northeast India.',
      eligibility: ['Age: 10-22 years', 'Physical fitness test', 'Commitment to training'],
      type: 'Grant',
      location: 'Guwahati, Assam',
      sport: 'Archery',
      minAge: 10,
      maxAge: 22,
      latitude: 26.1445,
      longitude: 91.7362,
      isForParaSport: false,
      programType: 'Day Program',
      facilities: ['Traditional Bows', 'Modern Equipment', 'Expert Coaches', 'Competition Preparation'],
      applicationDeadline: DateTime(2025, 7, 20),
    ),
    Scheme(
      title: 'Adaptive Badminton Championship',
      organization: 'Delhi Paralympic Sports Association',
      description: 'Inclusive badminton program for athletes with physical disabilities, focusing on competitive excellence.',
      eligibility: ['Age: 16-30 years', 'Disability classification', 'Intermediate skill level'],
      type: 'Sponsorship',
      location: 'New Delhi, Delhi',
      sport: 'Badminton',
      minAge: 16,
      maxAge: 30,
      latitude: 28.7041,
      longitude: 77.1025,
      isForParaSport: true,
      programType: 'Residential',
      facilities: ['Adaptive Courts', 'Specialized Coaching', 'Equipment Support', 'Tournament Preparation'],
      applicationDeadline: DateTime(2025, 10, 15),
    ),
    Scheme(
      title: 'Wrestling Championship Program',
      organization: 'Haryana Wrestling Federation',
      description: 'Intensive wrestling training program following traditional Indian wrestling techniques combined with modern methods.',
      eligibility: ['Age: 14-24 years', 'Physical strength assessment', 'Dedication to training'],
      type: 'Scholarship',
      location: 'Chandigarh, Haryana',
      sport: 'Wrestling',
      minAge: 14,
      maxAge: 24,
      latitude: 30.7333,
      longitude: 76.7794,
      isForParaSport: false,
      programType: 'Residential',
      facilities: ['Traditional Akhada', 'Modern Gym', 'Nutrition Support', 'Medical Care'],
      applicationDeadline: DateTime(2025, 5, 31),
    ),
  ];

  static List<Scheme> getAllSchemes() => _allSchemes;

  static List<Scheme> searchSchemes({
    String? sport,
    String? location,
    String? type,
    int? maxAge,
    bool? isForParaSport,
  }) {
    return _allSchemes.where((scheme) {
      if (sport != null && !scheme.sport.toLowerCase().contains(sport.toLowerCase())) return false;
      if (location != null && !scheme.location.toLowerCase().contains(location.toLowerCase())) return false;
      if (type != null && scheme.type != type) return false;
      if (maxAge != null && scheme.minAge > maxAge) return false;
      if (isForParaSport != null && scheme.isForParaSport != isForParaSport) return false;
      return true;
    }).toList();
  }

  static List<String> getSports() {
    return _allSchemes.map((scheme) => scheme.sport).toSet().toList()..sort();
  }

  static List<String> getTypes() {
    return _allSchemes.map((scheme) => scheme.type).toSet().toList()..sort();
  }
}