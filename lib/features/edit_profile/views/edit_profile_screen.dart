import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/edit_profile.dart';
import '../viewmodels/edit_profile_viewmodel.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all editable fields
  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController avatarController;
  late TextEditingController bioController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController regionController;
  late TextEditingController postalCodeController;
  late TextEditingController businessNameController;
  late TextEditingController licenseNumberController;
  late TextEditingController insuranceDetailsController;
  late TextEditingController yearsExperienceController;
  late TextEditingController hourlyRateController;
  late TextEditingController availabilityStatusController;
  late TextEditingController serviceRadiusController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(editProfileViewModelProvider.notifier).loadProfile();
    });

    firstNameController = TextEditingController();
    middleNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    avatarController = TextEditingController();
    bioController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    regionController = TextEditingController();
    postalCodeController = TextEditingController();
    businessNameController = TextEditingController();
    licenseNumberController = TextEditingController();
    insuranceDetailsController = TextEditingController();
    yearsExperienceController = TextEditingController();
    hourlyRateController = TextEditingController();
    availabilityStatusController = TextEditingController();
    serviceRadiusController = TextEditingController();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    avatarController.dispose();
    bioController.dispose();
    addressController.dispose();
    cityController.dispose();
    regionController.dispose();
    postalCodeController.dispose();
    businessNameController.dispose();
    licenseNumberController.dispose();
    insuranceDetailsController.dispose();
    yearsExperienceController.dispose();
    hourlyRateController.dispose();
    availabilityStatusController.dispose();
    serviceRadiusController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  void _populateControllers(EditProfile profile) {
    firstNameController.text = profile.firstName ?? '';
    middleNameController.text = profile.middleName ?? '';
    lastNameController.text = profile.lastName ?? '';
    phoneController.text = profile.phone ?? '';
    avatarController.text = profile.avatar ?? '';
    bioController.text = profile.bio ?? '';
    addressController.text = profile.address ?? '';
    cityController.text = profile.city ?? '';
    regionController.text = profile.region ?? '';
    postalCodeController.text = profile.postalCode ?? '';
    businessNameController.text = profile.businessName ?? '';
    licenseNumberController.text = profile.licenseNumber ?? '';
    insuranceDetailsController.text = profile.insuranceDetails ?? '';
    yearsExperienceController.text =
        profile.yearsExperience?.toString() ?? '';
    hourlyRateController.text = profile.hourlyRate?.toString() ?? '';
    availabilityStatusController.text = profile.availabilityStatus ?? '';
    serviceRadiusController.text = profile.serviceRadius?.toString() ?? '';
    latitudeController.text = profile.latitude?.toString() ?? '';
    longitudeController.text = profile.longitude?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          _populateControllers(profile);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: middleNameController,
                    decoration:
                    const InputDecoration(labelText: 'Middle Name'),
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  TextFormField(
                    controller: avatarController,
                    decoration: const InputDecoration(labelText: 'Avatar URL'),
                  ),
                  TextFormField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'Bio'),
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  TextFormField(
                    controller: regionController,
                    decoration: const InputDecoration(labelText: 'Region'),
                  ),
                  TextFormField(
                    controller: postalCodeController,
                    decoration: const InputDecoration(labelText: 'Postal Code'),
                  ),
                  TextFormField(
                    controller: businessNameController,
                    decoration:
                    const InputDecoration(labelText: 'Business Name'),
                  ),
                  TextFormField(
                    controller: licenseNumberController,
                    decoration:
                    const InputDecoration(labelText: 'License Number'),
                  ),
                  TextFormField(
                    controller: insuranceDetailsController,
                    decoration:
                    const InputDecoration(labelText: 'Insurance Details'),
                  ),
                  TextFormField(
                    controller: yearsExperienceController,
                    decoration:
                    const InputDecoration(labelText: 'Years of Experience'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: hourlyRateController,
                    decoration: const InputDecoration(labelText: 'Hourly Rate'),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                  ),
                  TextFormField(
                    controller: availabilityStatusController,
                    decoration:
                    const InputDecoration(labelText: 'Availability Status'),
                  ),
                  TextFormField(
                    controller: serviceRadiusController,
                    decoration:
                    const InputDecoration(labelText: 'Service Radius (km)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: latitudeController,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                  ),
                  TextFormField(
                    controller: longitudeController,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              context.go('/dashboard'), // Go to dashboard
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            final editProfile = EditProfile(
                              firstName: firstNameController.text,
                              middleName: middleNameController.text,
                              lastName: lastNameController.text,
                              phone: phoneController.text,
                              avatar: avatarController.text,
                              bio: bioController.text,
                              address: addressController.text,
                              city: cityController.text,
                              region: regionController.text,
                              postalCode: postalCodeController.text,
                              businessName: businessNameController.text,
                              licenseNumber: licenseNumberController.text,
                              insuranceDetails:
                              insuranceDetailsController.text,
                              yearsExperience: int.tryParse(
                                  yearsExperienceController.text),
                              hourlyRate:
                              double.tryParse(hourlyRateController.text),
                              availabilityStatus:
                              availabilityStatusController.text,
                              serviceRadius:
                              int.tryParse(serviceRadiusController.text),
                              latitude:
                              double.tryParse(latitudeController.text),
                              longitude:
                              double.tryParse(longitudeController.text),
                            );

                            await ref
                                .read(editProfileViewModelProvider.notifier)
                                .updateProfile(editProfile);

                            final currentState =
                            ref.read(editProfileViewModelProvider);
                            currentState.whenOrNull(
                              data: (_) => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                  content: Text('Profile updated'))),
                              error: (e, _) => ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                  SnackBar(content: Text('$e'))),
                            );
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
