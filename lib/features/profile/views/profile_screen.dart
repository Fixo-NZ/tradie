import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/profile_viewmodel.dart';
import '../models/profile_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileViewModelProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : state.profile == null
          ? const Center(child: Text('No profile data available'))
          : _buildProfileContent(context, state.profile!),
      bottomNavigationBar: state.profile != null
          ? Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeight,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to edit profile screen
              context.go('/edit-profile');
            },
            child: const Text('Edit Profile'),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileModel profile) {
    Widget buildRow(String label, String? value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(value ?? '-'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildRow('First Name', profile.firstName),
          buildRow('Middle Name', profile.middleName),
          buildRow('Last Name', profile.lastName),
          buildRow('Email', profile.email),
          buildRow('Phone', profile.phone),
          buildRow('Bio', profile.bio),
          buildRow('Address', profile.address),
          buildRow('City', profile.city),
          buildRow('Region', profile.region),
          buildRow('Postal Code', profile.postalCode),
          buildRow('Latitude', profile.latitude?.toString()),
          buildRow('Longitude', profile.longitude?.toString()),
          buildRow('Business Name', profile.businessName),
          buildRow('License Number', profile.licenseNumber),
          buildRow('Insurance Details', profile.insuranceDetails),
          buildRow('Years Experience', profile.yearsExperience?.toString()),
          buildRow('Hourly Rate', profile.hourlyRate?.toString()),
          buildRow('Availability Status', profile.availabilityStatus),
          buildRow('Service Radius', profile.serviceRadius?.toString()),
        ],
      ),
    );
  }
}
