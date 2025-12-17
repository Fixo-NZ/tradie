import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_result.dart';
import '../repositories/job_application_repository.dart';
import '../models/job_applications_model.dart';

class JobApplicationState {
  final bool isLoading;
  final List<JobFeedItem>? availableJobs;
  final List<JobApplication>? myApplications;
  final String? error;
  final bool isApplying;
  final bool isCompleting;

  const JobApplicationState({
    this.isLoading = false,
    this.availableJobs,
    this.myApplications,
    this.error,
    this.isApplying = false,
    this.isCompleting = false,
  });

  JobApplicationState copyWith({
    bool? isLoading,
    List<JobFeedItem>? availableJobs,
    List<JobApplication>? myApplications,
    String? error,
    bool? isApplying,
    bool? isCompleting,
  }) {
    return JobApplicationState(
      isLoading: isLoading ?? this.isLoading,
      availableJobs: availableJobs ?? this.availableJobs,
      myApplications: myApplications ?? this.myApplications,
      error: error ?? this.error,
      isApplying: isApplying ?? this.isApplying,
      isCompleting: isCompleting ?? this.isCompleting,
    );
  }
}

class JobApplicationViewModel extends StateNotifier<JobApplicationState> {
  final JobApplicationRepository _repository;

  JobApplicationViewModel(this._repository)
      : super(const JobApplicationState());

  // Load available jobs (job feed)
  Future<void> loadAvailableJobs() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.getAvailableJobs();
    
    switch (result) {
      case Success<List<JobFeedItem>>():
        state = state.copyWith(
          isLoading: false,
          availableJobs: result.data,
        );
      case Failure<List<JobFeedItem>>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
    }
  }

  // Load tradie's applications
  Future<void> loadMyApplications() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.getMyApplications();
    
    switch (result) {
      case Success<List<JobApplication>>():
        state = state.copyWith(
          isLoading: false,
          myApplications: result.data,
        );
      case Failure<List<JobApplication>>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
    }
  }

  // Apply to a job
  Future<bool> applyToJob(int jobId, {String? message}) async {
    state = state.copyWith(isApplying: true, error: null);
    
    final result = await _repository.applyToJob(jobId, message: message);
    
    switch (result) {
      case Success<JobApplication>():
        // Remove from available jobs
        final updatedAvailableJobs = state.availableJobs
            ?.where((job) => job.id != jobId)
            .toList();
        
        // Add to my applications
        final updatedMyApplications = <JobApplication>[
          result.data,
          ...(state.myApplications ?? []),
        ];
        
        state = state.copyWith(
          isApplying: false,
          availableJobs: updatedAvailableJobs,
          myApplications: updatedMyApplications,
        );
        return true;
      case Failure<JobApplication>():
        state = state.copyWith(
          isApplying: false,
          error: result.message,
        );
        return false;
    }
  }

  // Complete a job
  Future<bool> completeJob(int jobId) async {
    state = state.copyWith(isCompleting: true, error: null);
    
    final result = await _repository.completeJob(jobId);
    
    switch (result) {
      case Success<JobApplicationResponse>():
        // Update application status
        final updatedApplications = state.myApplications
            ?.map((app) => app.jobOfferId == jobId
                ? app.copyWith(status: 'completed')
                : app)
            .toList();
        
        state = state.copyWith(
          isCompleting: false,
          myApplications: updatedApplications,
        );
        return true;
      case Failure<JobApplicationResponse>():
        state = state.copyWith(
          isCompleting: false,
          error: result.message,
        );
        return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final jobApplicationRepositoryProvider = Provider<JobApplicationRepository>((ref) {
  return JobApplicationRepository();
});

final jobApplicationViewModelProvider =
    StateNotifierProvider<JobApplicationViewModel, JobApplicationState>((ref) {
  final repository = ref.watch(jobApplicationRepositoryProvider);
  return JobApplicationViewModel(repository);
});