import 'dart:convert';
import 'api_service.dart';

class AvailabilityApiService extends ApiService {

  Future<bool> updateAvailability({
    required List<String> days,
    String? fromTime, 
    String? toTime,   
    required bool emergencyAvailable,
  }) async {
    final endpoint = '/profile-setup/availability'; 

    final body = {
  if (days.isNotEmpty)
  "working_hours": days.map((dayName) {
    final dayMapping = {
      "Mon": 1,
      "Tue": 2,
      "Wed": 3,
      "Thu": 4,
      "Fri": 5,
      "Sat": 6,
      "Sun": 0,
    };

    return {
      "day": dayMapping[dayName] ?? 0, // default to Sunday if not found
      if (fromTime != null && fromTime.isNotEmpty)
        "start": _convertTo24Hour(fromTime),
      if (toTime != null && toTime.isNotEmpty)
        "end": _convertTo24Hour(toTime),
    };
  }).toList(),
  "emergency_available": emergencyAvailable,
};

    final response = await post(endpoint, body);
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      print("✅ Availability saved successfully!");
      return true;
    } else {
      print("❌ Failed to save availability: ${decoded['error'] ?? decoded}");
      return false;
    }
  }

  String _convertTo24Hour(String time12h) {
    try {
      final time = DateTime.parse("2024-01-01 ${_to24HourFormat(time12h)}:00");
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      print("⚠️ Failed to convert time: $time12h");
      return "00:00";
    }
  }

  String _to24HourFormat(String time12h) {
    // Converts "08:00 AM" -> "08:00", "05:00 PM" -> "17:00"
    final isPM = time12h.toUpperCase().contains("PM");
    final parts = time12h.replaceAll(RegExp(r'[^0-9:]'), '').split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }
}
