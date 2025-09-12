import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/nutrition_model.dart';

class LocationService {
  static Future<LocationContext> getCurrentLocation() async {
    print('Starting location detection...');
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Location services enabled: $serviceEnabled');
      if (!serviceEnabled) {
        return _getDefaultLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('Permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('Permission after request: $permission');
        if (permission == LocationPermission.denied) {
          return _getDefaultLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _getDefaultLocation();
      }

      print('Getting position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 15),
      );
      print('Position: ${position.latitude}, ${position.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      print('Placemarks found: ${placemarks.length}');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.subAdministrativeArea ?? 'Unknown';
        String country = place.country ?? 'Unknown';
        print('Location: $city, $country');
        
        return LocationContext(
          city: city,
          country: country,
          climate: getClimateForCountry(country),
          localFoods: getLocalFoods(country),
          isAutoDetected: true,
        );
      }
    } catch (e) {
      print('Location error: $e');
    }
    
    return _getDefaultLocation();
  }

  static LocationContext _getDefaultLocation() {
    return LocationContext(
      city: 'New York',
      country: 'USA',
      climate: 'Temperate',
      localFoods: ['Apples', 'Salmon', 'Quinoa'],
      isAutoDetected: false,
    );
  }

  static String getClimateForCountry(String country) {
    final climates = {
      'United States': 'Temperate',
      'USA': 'Temperate',
      'India': 'Tropical',
      'Canada': 'Cold',
      'Australia': 'Arid',
      'Brazil': 'Tropical',
      'United Kingdom': 'Temperate',
      'UK': 'Temperate',
    };
    return climates[country] ?? 'Temperate';
  }

  static List<String> getLocalFoods(String country) {
    final foods = {
      'United States': ['Apples', 'Salmon', 'Quinoa'],
      'USA': ['Apples', 'Salmon', 'Quinoa'],
      'India': ['Rice', 'Lentils', 'Mangoes'],
      'Canada': ['Maple Syrup', 'Salmon', 'Blueberries'],
      'Australia': ['Kangaroo', 'Macadamia', 'Barramundi'],
      'Brazil': ['Acai', 'Cashews', 'Guarana'],
      'United Kingdom': ['Oats', 'Fish', 'Berries'],
      'UK': ['Oats', 'Fish', 'Berries'],
    };
    return foods[country] ?? ['Local Produce'];
  }
}