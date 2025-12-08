import 'package:dio/dio.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final DioClient _dioClient = DioClient.instance;

  Future<ApiResult<List<ScheduleModel>>> getSchedules() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.schedulesEndpoint);
      final data = response.data;

      if (data is Map<String, dynamic> && data['schedules'] is List) {
        final schedules = (data['schedules'] as List)
            .map((json) => ScheduleModel.fromJson(json))
            .toList();
        return Success(schedules);
      }

      return const Failure(message: 'Unexpected response format');
    } on DioException catch (e) {
      return Failure(message: 'Network error: ${e.message}');
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  Future<ApiResult<ScheduleModel>> rescheduleEvent({
    required int id,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // Format dates to match the format that works in Postman
      final startTimeString = '${startTime.year.toString().padLeft(4, '0')}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')} ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
      final endTimeString = '${endTime.year.toString().padLeft(4, '0')}-${endTime.month.toString().padLeft(2, '0')}-${endTime.day.toString().padLeft(2, '0')} ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';
      
      print("🚀 Sending reschedule request:");
      print("📅 Start Time: $startTimeString");
      print("📅 End Time: $endTimeString");
      
      final response = await _dioClient.dio.post(
        '${ApiConstants.schedulesEndpoint}/$id/reschedule',
        data: {
          'start_time': startTimeString,
          'end_time': endTimeString,
        },
      );

      final updatedSchedule = ScheduleModel.fromJson(response.data['schedule']);
      
      // Log successful update for debugging
      print("✅ Schedule updated successfully: ${updatedSchedule.id}");
      
      return Success(updatedSchedule);
    } on DioException catch (e) {
      print("❌ Reschedule API Error: ${e.response?.data}");
      return Failure(message: 'Network error: ${e.message}');
    } catch (e) {
      print("❌ Reschedule Error: $e");
      return Failure(message: 'Unexpected error: $e');
    }
  }

  Future<ApiResult<ScheduleModel>> cancelSchedule(int id) async {
    try {
      final response = await _dioClient.dio.post('${ApiConstants.schedulesEndpoint}/$id/cancel');

      final cancelledSchedule = ScheduleModel.fromJson(response.data['schedule']);
      
      // Log successful cancellation for debugging
      print("✅ Schedule cancelled successfully: ${cancelledSchedule.id}");
      
      return Success(cancelledSchedule);
    } on DioException catch (e) {
      print("❌ Cancel API Error: ${e.response?.data}");
      return Failure(message: 'Network error: ${e.message}');
    } catch (e) {
      print("❌ Cancel Error: $e");
      return Failure(message: 'Unexpected error: $e');
    }
  }
}
