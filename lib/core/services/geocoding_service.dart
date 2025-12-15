import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  // Convert address to coordinates (geocoding)
  static Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    if (address.trim().isEmpty) return null;
    
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = '$_baseUrl/search?q=$encodedAddress&format=json&limit=1&addressdetails=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Tradie App (com.fixo.tradie.tradie)',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final result = results[0];
          return {
            'latitude': double.parse(result['lat']),
            'longitude': double.parse(result['lon']),
            'display_name': result['display_name'],
            'address': result['address'] ?? {},
          };
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    
    return null;
  }
  
  // Convert coordinates to address (reverse geocoding)
  static Future<Map<String, dynamic>?> reverseGeocode(double latitude, double longitude) async {
    try {
      final url = '$_baseUrl/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Tradie App (com.fixo.tradie.tradie)',
        },
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final address = result['address'] ?? {};
        
        return {
          'address': _extractAddress(address),
          'city': _extractCity(address),
          'region': _extractRegion(address),
          'postal_code': _extractPostalCode(address),
          'display_name': result['display_name'] ?? '',
        };
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
    
    return null;
  }
  
  static String _extractAddress(Map<String, dynamic> address) {
    // Try different address components in order of preference
    return address['house_number'] != null && address['road'] != null
        ? '${address['house_number']} ${address['road']}'
        : address['road'] ?? 
          address['pedestrian'] ?? 
          address['residential'] ?? 
          address['suburb'] ?? 
          '';
  }
  
  static String _extractCity(Map<String, dynamic> address) {
    return address['city'] ?? 
           address['town'] ?? 
           address['village'] ?? 
           address['municipality'] ?? 
           address['suburb'] ?? 
           '';
  }
  
  static String _extractRegion(Map<String, dynamic> address) {
    return address['state'] ?? 
           address['region'] ?? 
           address['province'] ?? 
           address['county'] ?? 
           '';
  }
  
  static String _extractPostalCode(Map<String, dynamic> address) {
    return address['postcode'] ?? '';
  }
}