import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/profile_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
//import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/snackbar_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load profile once
    Future.microtask(
      () => ref.read(profileViewModelProvider.notifier).loadProfile(),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    // Listen to state changes in build context (safe to use context here)
    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      // When profile arrives, populate controllers once
      if (next.profile != null && previous?.profile?.id != next.profile!.id) {
        _firstNameCtrl.text = next.profile!.firstName ?? '';
        _lastNameCtrl.text = next.profile!.lastName ?? '';
        _phoneCtrl.text = next.profile!.phone ?? '';
      }

      // Show error toast/snackbar
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ref
            .read(snackBarProvider.notifier)
            .show(next.errorMessage!, backgroundColor: AppColors.error);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tradie Profile'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: state.isLoading && state.profile == null
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.profile == null
          ? Center(child: Text(state.errorMessage!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppDimensions.spacing24),
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final success = await ref
                                      .read(profileViewModelProvider.notifier)
                                      .updateProfile({
                                        'first_name': _firstNameCtrl.text
                                            .trim(),
                                        'last_name': _lastNameCtrl.text.trim(),
                                        'phone': _phoneCtrl.text.trim(),
                                      });

                                  if (!mounted) return;

                                  if (success) {
                                    ref
                                        .read(snackBarProvider.notifier)
                                        .show('Profile updated');
                                    // optionally navigate back:
                                    // context.pop();
                                  }
                                }
                              },
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
