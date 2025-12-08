import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/dio_client.dart';

class ApiTestHelper {
  static final DioClient _dioClient = DioClient.instance;

  /// Test creating a job offer via API
  static Future<void> testCreateJobOffer() async {
    try {
      if (kDebugMode) {
        print('🧪 Testing job offer creation...');
      }

      final response = await _dioClient.dio.post(
        '/jobs/job-offers',
        data: {
          'service_category_id': 1,
          'title': 'Test Job from Flutter Debug',
          'description': 'This is a test job offer created from Flutter debug screen',
          'job_type': 'standard',
          'preferred_date': DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
          'job_size': 'medium',
          'address': 'Test Address from Flutter',
          'latitude': 14.5547,
          'longitude': 121.0244,
          'services': [1],
          'photos': [],
          'tradie_id': 12, // This is crucial for broadcasting!
        },
      );

      if (kDebugMode) {
        print('✅ Job offer created successfully!');
        print('📡 Response: ${response.data}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Failed to create job offer: ${e.message}');
        print('📡 Response: ${e.response?.data}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
      }
    }
  }

  /// Test the broadcast endpoint
  static Future<void> testBroadcast() async {
    try {
      if (kDebugMode) {
        print('🧪 Testing broadcast endpoint...');
      }

      final response = await _dioClient.dio.get('/test-broadcast');

      if (kDebugMode) {
        print('✅ Broadcast test successful!');
        print('📡 Response: ${response.data}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Failed to test broadcast: ${e.message}');
        print('📡 Response: ${e.response?.data}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
      }
    }
  }

  /// Get current schedules
  static Future<void> testGetSchedules() async {
    try {
      if (kDebugMode) {
        print('🧪 Testing get schedules...');
      }

      final response = await _dioClient.dio.get('/schedules');

      if (kDebugMode) {
        print('✅ Schedules retrieved successfully!');
        print('📡 Response: ${response.data}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get schedules: ${e.message}');
        print('📡 Response: ${e.response?.data}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
      }
    }
  }
}