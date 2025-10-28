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
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.schedulesEndpoint}/$id/reschedule',
        data: {
          'date': date.toIso8601String(),
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
        },
      );

      return Success(ScheduleModel.fromJson(response.data['schedule']));
    } on DioException catch (e) {
      return Failure(message: 'Network error: ${e.message}');
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  Future<ApiResult<ScheduleModel>> cancelSchedule(int id) async {
    try {
      final response = await _dioClient.dio.post('${ApiConstants.schedulesEndpoint}/$id/cancel');

      return Success(ScheduleModel.fromJson(response.data['schedule']));
    } on DioException catch (e) {
      return Failure(message: 'Network error: ${e.message}');
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }
}
