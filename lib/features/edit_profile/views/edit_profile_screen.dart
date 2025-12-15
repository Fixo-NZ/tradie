import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/edit_profile.dart';
import '../viewmodels/edit_profile_viewmodel.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();

    // Load profile once after widget is mounted
    Future.microtask(() {
      ref.read(editProfileViewModelProvider.notifier).loadProfile();
    });

    // Initialize controllers
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    bioController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _populateControllers(EditProfile profile) {
    firstNameController.text = profile.firstName ?? '';
    lastNameController.text = profile.lastName ?? '';
    phoneController.text = profile.phone ?? '';
    bioController.text = profile.bio ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          // populate controllers with current data
          _populateControllers(profile as EditProfile);

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
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  TextFormField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'Bio'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final editProfile = EditProfile(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        phone: phoneController.text,
                        bio: bioController.text,
                      );

                      await ref
                          .read(editProfileViewModelProvider.notifier)
                          .updateProfile(editProfile);

                      // Optional: show snackbar on success or error
                      final currentState =
                      ref.read(editProfileViewModelProvider);
                      currentState.whenOrNull(
                        data: (_) => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                            content: Text('Profile updated'))),
                        error: (e, _) => ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('$e'))),
                      );
                    },
                    child: const Text('Save'),
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
