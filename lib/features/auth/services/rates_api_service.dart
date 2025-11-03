import 'dart:convert';
import '../services/api_service.dart';

class RatesApiService extends ApiService {
  // Save or update tradie's rate and related settings
  Future<bool> saveRates({
    required int chargeMode, 
    String? hourlyRate,      
    int? minimumHours,       
    bool? afterHours,
    bool? callOut,
    String? description,
  }) async {
    String chargeType;
    switch (chargeMode) {
      case 0:
        chargeType = 'hourly';
        break;
      case 1:
        chargeType = 'fixed';
        break;
      default:
        chargeType = 'both';
        break;
    }

    // Parse rate safely — null if blank or invalid
    final double? parsedRate = (hourlyRate != null && hourlyRate.isNotEmpty)
        ? double.tryParse(hourlyRate)
        : null;

    // Prepare request body
    final Map<String, dynamic> body = {
    'rate_type': chargeType, 
    if (parsedRate != null) 'standard_rate': parsedRate,
    if (minimumHours != null) 'minimum_hours': minimumHours,
    if (description?.isNotEmpty == true)
      'standard_rate_description': description,
    'after_hours': afterHours == true ? 1 : 0,  
  'call_out_fee': callOut == true ? 1 : 0,     
  };


    // Send POST request to Laravel endpoint
    final response = await post('/profile-setup/portfolio', body);

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print("✅ Rates saved successfully!");
        return true;
      } else {
        print("❌ Failed to save rates: ${data['error'] ?? data}");
        return false;
      }
    } catch (e) {
      print("❌ Error decoding response: $e");
      return false;
    }
  }
}
