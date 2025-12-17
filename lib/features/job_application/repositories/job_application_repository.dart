import 'package:dio/dio.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/job_applications_model.dart';


class JobApplicationRepository {
  final DioClient _dioClient = DioClient.instance;

  // Get available jobs for tradies (job feed)
  Future<ApiResult<List<JobFeedItem>>> getAvailableJobs() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.availableJobsEndpoint}',
      );

      final List<dynamic> data = response.data['data'] ?? [];
      final jobs = data.map((job) => JobFeedItem.fromJson(job)).toList();

      return Success(jobs);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // Get tradie's applications
  Future<ApiResult<List<JobApplication>>> getMyApplications() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.myApplicationsEndpoint}',
      );

      final List<dynamic> data = response.data['data'] ?? [];
      final applications = data
          .map((app) => JobApplication.fromJson(app))
          .toList();

      return Success(applications);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // Apply to a job
  Future<ApiResult<JobApplication>> applyToJob(
    int jobId, {
    String? message,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.applyJobEndpoint}/$jobId/apply',
        data: ApplyJobRequest(message: message).toJson(),
      );

      final data = response.data['data'] ?? response.data;
      final application = JobApplication.fromJson(data);

      return Success(application);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // Mark job as completed
  Future<ApiResult<JobApplicationResponse>> completeJob(int jobId) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.completeJobEndpoint}/$jobId/complete',
      );

      final jobResponse = JobApplicationResponse.fromJson(response.data);
      return Success(jobResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // Error handling
  ApiResult<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? 'An error occurred';
        return Failure(
          message: message,
          statusCode: e.response!.statusCode,
        );
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return const Failure(message: 'No internet connection.');
      default:
        return Failure(message: 'Network error: ${e.message}');
    }
  }
}