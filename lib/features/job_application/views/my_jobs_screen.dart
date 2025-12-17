import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../viewmodels/job_application_viewmodel.dart';
import '../models/job_applications_model.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobApplicationViewModelProvider.notifier).loadMyApplications();
    });
  }

  Future<void> _completeJob(int jobId) async {
    final success = await ref
        .read(jobApplicationViewModelProvider.notifier)
        .completeJob(jobId);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job completion requested!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobApplicationViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(jobApplicationViewModelProvider.notifier)
                .loadMyApplications(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(JobApplicationState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading jobs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref
                  .read(jobApplicationViewModelProvider.notifier)
                  .loadMyApplications(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final applications = state.myApplications ?? [];

    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'No jobs yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Apply to jobs from the job feed',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/job-feed'),
              child: const Text('Browse Jobs'),
            ),
          ],
        ),
      );
    }

    // Group applications by status
    final pendingApps = applications.where((a) => a.isPending).toList();
    final acceptedApps = applications.where((a) => a.isAccepted).toList();
    final completedApps = applications.where((a) => a.isCompleted).toList();
    final rejectedApps = applications.where((a) => a.isRejected).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (acceptedApps.isNotEmpty) ...[
          _buildStatusSection('Active Jobs', acceptedApps, Colors.green),
          const SizedBox(height: 24),
        ],
        if (pendingApps.isNotEmpty) ...[
          _buildStatusSection('Pending Applications', pendingApps, Colors.orange),
          const SizedBox(height: 24),
        ],
        if (completedApps.isNotEmpty) ...[
          _buildStatusSection('Completed Jobs', completedApps, Colors.blue),
          const SizedBox(height: 24),
        ],
        if (rejectedApps.isNotEmpty) ...[
          _buildStatusSection('Rejected Applications', rejectedApps, Colors.red),
        ],
      ],
    );
  }

  Widget _buildStatusSection(
    String title,
    List<JobApplication> applications,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(applications.length.toString()),
              backgroundColor: color.withOpacity(0.1),
              labelStyle: TextStyle(color: color),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...applications.map((app) => _buildApplicationCard(app)),
      ],
    );
  }

  Widget _buildApplicationCard(JobApplication app) {
    final job = app.jobOffer;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job?['title'] ?? 'Job #${app.jobOfferId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(app.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    app.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (job?['description'] != null)
              Text(
                job!['description'],
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  app.homeowner?['name'] ?? 'Homeowner',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                if (app.appliedAt.isNotEmpty)
                  Text(
                    DateFormat('MMM d').format(DateTime.parse(app.appliedAt)),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            
            if (app.isAccepted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _completeJob(app.jobOfferId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark as Complete'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}