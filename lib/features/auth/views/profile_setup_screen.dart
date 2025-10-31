// lib/screens/profile_setup/profile_setup_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'skills_setup_screen.dart';
import '../viewmodels/profile_setup_viewmodel.dart';


class ProfileSetupScreen extends ConsumerWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileSetupViewModelProvider.notifier);
    final state = ref.watch(profileSetupViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'Create Profile',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ContinueFloatingButton(
        onPressed: () async {
  if (state.firstName.isNotEmpty &&
      state.lastName.isNotEmpty &&
      state.email.isNotEmpty &&
      state.businessName.isNotEmpty &&
      state.phone.isNotEmpty) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await viewModel.submitBasicInfo();

    if (context.mounted) Navigator.pop(context); // close loader

    if (success) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SkillsSetupScreen()),
        );
      }
    } else {
      final message = state.errorMessage ?? 'Failed to save profile';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all required fields')),
    );
  }
},
        backgroundColor: const Color(0xFF0000A8),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.spacing8,
          ),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: 1 / 6,
                  minHeight: 4,
                  color: const Color(0xFF0000A8),
                  backgroundColor: const Color(0xFFDDE9FF),
                ),
                const SizedBox(height: AppDimensions.spacing16),

                // Section title
                Text(
                  'Basic Information',
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: const Color(0xFF0000A8), fontSize: 18),
                ),
                const SizedBox(height: AppDimensions.spacing12),

                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: state.firstName,
                          decoration: InputDecoration(
                            labelText: 'First Name *',
                            labelStyle:
                                AppTextStyles.inputLabel.copyWith(fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF0000A8), width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: AppTextStyles.inputText.copyWith(fontSize: 17),
                          onChanged: viewModel.updateFirstName,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          initialValue: state.lastName,
                          decoration: InputDecoration(
                            labelText: 'Last Name *',
                            labelStyle:
                                AppTextStyles.inputLabel.copyWith(fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF0000A8), width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: AppTextStyles.inputText.copyWith(fontSize: 17),
                          onChanged: viewModel.updateLastName,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          initialValue: state.email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email *',
                            labelStyle:
                                AppTextStyles.inputLabel.copyWith(fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF0000A8), width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: AppTextStyles.inputText.copyWith(fontSize: 17),
                          onChanged: viewModel.updateEmail,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          initialValue: state.phone.isEmpty ? '+64' : state.phone,
                          keyboardType: TextInputType.phone,
                          autofillHints: [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: 'Phone *',
                            labelStyle:
                                AppTextStyles.inputLabel.copyWith(fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF0000A8), width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: AppTextStyles.inputText.copyWith(fontSize: 17),
                          onChanged: (value) {
                            var cleaned = value.trim();
                            if (cleaned.isEmpty) {
                              cleaned = '+64';
                            } else if (!cleaned.startsWith('+64')) {
                              // Remove any leading plus signs and prepend +64
                              cleaned = '+64' + cleaned.replaceFirst(RegExp(r'^\++'), '');
                            }
                            viewModel.updatePhone(cleaned);
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          initialValue: state.businessName,
                          decoration: InputDecoration(
                            labelText: 'Business Name *',
                            labelStyle:
                                AppTextStyles.inputLabel.copyWith(fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF0000A8), width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: AppTextStyles.inputText.copyWith(fontSize: 17),
                          onChanged: viewModel.updateBusinessName,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          initialValue: state.professionalBio,
                          decoration: InputDecoration(
                            labelText: 'Professional Bio',
                            labelStyle:
                                AppTextStyles.inputLabel.copyWith(fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF0000A8), width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: AppTextStyles.inputText.copyWith(fontSize: 17),
                          onChanged: viewModel.updateProfessionalBio,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 24),

                        // Profile picture chooser container left as-is (your teammate)
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spacing12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.surfaceVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          height: 185,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    width: 110,
                                    height: 110,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.surfaceVariant,
                                          width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 54,
                                      backgroundColor: AppColors.surfaceVariant,
                                      backgroundImage: state.pickedImage != null
                                          ? FileImage(state.pickedImage!)
                                          : null,
                                      child: state.pickedImage == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 55,
                                              color: AppColors.onSurface,
                                            )
                                          : null,
                                    ),
                                  ),
                                  if (state.pickedImage != null)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          viewModel.removeImage();
                                        },
                                        child: Container(
                                          child: const Icon(Icons.close,
                                              size: 20, color: Colors.redAccent),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Profile Picture',
                                      style:
                                          AppTextStyles.inputLabel.copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 130,
                                      height: 38,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final picker = ImagePicker();
                                          final pickedFile = await picker.pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 80,
                                          );
                                          if (pickedFile != null) {
                                            viewModel.setPickedImage(File(pickedFile.path));
                                          }
                                        },
                                        icon: const Icon(Icons.upload_file, size: 16),
                                        label: const Text(
                                          'Choose File',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0000A8),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'JPG, PNG, GIF, max of 5mb',
                                      style: AppTextStyles.inputText.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
