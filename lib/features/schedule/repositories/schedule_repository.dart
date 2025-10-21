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

      if (response.data is List) {
        final schedules = (response.data as List)
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
}
