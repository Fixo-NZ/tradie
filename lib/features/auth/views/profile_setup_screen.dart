//lib/screens/profile_setup/profile_setup_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'license_upload_screen.dart';
import '../viewmodels/profile_setup_viewmodel.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  // Controllers for fields we need to programmatically update
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  // Form key to validate inputs before submission
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Formatting guard to avoid recursion inside listeners
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(profileSetupViewModelProvider);

    // Initialize controllers with current state values (or defaults)
    _firstNameController = TextEditingController(text: state.firstName);
    _lastNameController = TextEditingController(text: state.lastName);
    _phoneController = TextEditingController(text: state.phone.isEmpty ? '+64 ' : state.phone);

    // Listeners
    _firstNameController.addListener(_onFirstNameChanged);
    _lastNameController.addListener(_onLastNameChanged);
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_onFirstNameChanged);
    _lastNameController.removeListener(_onLastNameChanged);
    _phoneController.removeListener(_onPhoneChanged);

    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Capitalize the first letter of each word
  String capitalizeWords(String value) {
    if (value.trim().isEmpty) return value;
    return value.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).join(' ');
  }

  // First name listener
  void _onFirstNameChanged() {
    if (_isFormatting) return;
    _isFormatting = true;

    final raw = _firstNameController.text;
    final formatted = capitalizeWords(raw);

    if (formatted != raw) {
      // preserve caret position at end (simple approach)
      _firstNameController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Update view model
    ref.read(profileSetupViewModelProvider.notifier).updateFirstName(formatted);
    _isFormatting = false;
  }

  // Last name listener
  void _onLastNameChanged() {
    if (_isFormatting) return;
    _isFormatting = true;

    final raw = _lastNameController.text;
    final formatted = capitalizeWords(raw);

    if (formatted != raw) {
      _lastNameController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Update view model
    ref.read(profileSetupViewModelProvider.notifier).updateLastName(formatted);
    _isFormatting = false;
  }

  void _onPhoneChanged() {
    if (_isFormatting) return;
    _isFormatting = true;

    String current = _phoneController.text;

    if (!current.startsWith('+64 ')) {
      current = '+64 ';
    }

    String digitsOnly = current.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.startsWith('64')) {
      digitsOnly = digitsOnly.substring(2);
    }

    if (digitsOnly.length > 9) {
      digitsOnly = digitsOnly.substring(0, 9);
    }

    // Build formatted string: +64 XX XXXX XXX (2-4-3 groups)
    final buffer = StringBuffer('+64 ');
    if (digitsOnly.length >= 1) {
      if (digitsOnly.length >= 2) {
        buffer.write(digitsOnly.substring(0, 2));
      } else {
        buffer.write(digitsOnly.substring(0, 1));
      }
    }
    if (digitsOnly.length > 2) {
      final end = digitsOnly.length.clamp(2, 6);
      buffer.write(' ');
      buffer.write(digitsOnly.substring(2, end));
    }
    if (digitsOnly.length > 6) {
      buffer.write(' ');
      buffer.write(digitsOnly.substring(6));
    }

    final formatted = buffer.toString();

    // Update controller text and place cursor at the end
    _phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    // Update view model
    ref.read(profileSetupViewModelProvider.notifier).updatePhone(formatted);

    _isFormatting = false;
  }

  @override
  Widget build(BuildContext context) {
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
        // Trigger form validation
        final isValid = _formKey.currentState?.validate() ?? false;

        if (!isValid) {
          final state = ref.read(profileSetupViewModelProvider);

          final hasEmptyRequiredField =
              state.firstName.trim().isEmpty ||
              state.lastName.trim().isEmpty ||
              state.email.trim().isEmpty ||
              state.phone.trim().isEmpty ||
              state.businessName.trim().isEmpty;

          if (hasEmptyRequiredField) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fill out all required field'),
              ),
            );
          }
          return;
        }

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
                  MaterialPageRoute(builder: (_) => const LicenseUploadScreen()),
                );
              }
            } else {
            final message = state.errorMessage ?? 'Failed to save profile';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
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
            key: _formKey,
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
                Text(
                  'Basic Information',
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: const Color(0xFF0000A8), fontSize: 18),
                ),
                const SizedBox(height: AppDimensions.spacing12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First Name
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name is required';
                            }
                            if (!RegExp(r'^[A-Z][a-zA-Z ]*$').hasMatch(value)) {
                              return 'Enter valid name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Last Name 
                        TextFormField(
                          controller: _lastNameController, 
                          decoration: InputDecoration(
                            labelText: 'Last Name',
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            if (!RegExp(r'^[A-Z][a-zA-Z ]*$').hasMatch(value)) {
                              return 'Enter valid name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          initialValue: state.email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email',
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }

                            // Check for @ symbol
                            if (!value.contains('@')) {
                              return 'Enter valid email';
                            }

                            // Check for domain with TLD (. after @)
                            final parts = value.split('@');
                            if (parts.length != 2 || !parts[1].contains('.')) {
                              return 'Enter valid email';
                            }

                            // Basic email format validation
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              caseSensitive: false,
                            );

                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Enter valid email';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone 
                        TextFormField(
                          controller: _phoneController, 
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            labelStyle: AppTextStyles.inputLabel.copyWith(fontSize: 18),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF0000A8), width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: AppTextStyles.inputText.copyWith(fontSize: 17),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty || value.trim() == '+64') {
                              return 'Phone number is required';
                            }

                            if (!value.startsWith('+64 ')) {
                              return 'Enter valid phone number';
                            }

                            final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                            final nzDigits = digits.length >= 2 ? digits.substring(2) : '';

                            if (nzDigits.length != 9) {
                              return 'Enter valid phone number';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Business name 
                        TextFormField(
                          initialValue: state.businessName,
                          decoration: InputDecoration(
                            labelText: 'Business Name',
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Business name is required';
                            }
                            return null;
                          },
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

                        // Profile picture chooser container 
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
                              _AvatarPreview(
                                pickedImage: state.pickedImage,
                                onRemove: () async {
                                  await viewModel.removeImage();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Profile picture removed')),
                                    );
                                  }
                                },
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

// Small helper widget to display the picked avatar (uses in-memory bytes)
// and provide a reliable remove action that evicts caches on Android emulators.
class _AvatarPreview extends StatefulWidget {
  final File? pickedImage;
  final Future<void> Function()? onRemove;

  const _AvatarPreview({Key? key, this.pickedImage, this.onRemove}) : super(key: key);

  @override
  State<_AvatarPreview> createState() => _AvatarPreviewState();
}

class _AvatarPreviewState extends State<_AvatarPreview> {
  Uint8List? _bytes;
  Key? _imageKey;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  @override
  void didUpdateWidget(covariant _AvatarPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pickedImage?.path != oldWidget.pickedImage?.path) {
      _loadBytes();
    }
  }

  Future<void> _loadBytes() async {
    if (widget.pickedImage != null) {
      try {
        final b = await widget.pickedImage!.readAsBytes();
        if (!mounted) return;
        setState(() {
          _bytes = b;
          _imageKey = UniqueKey();
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _bytes = null;
          _imageKey = UniqueKey();
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        _bytes = null;
        _imageKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceVariant, width: 2),
          ),
          child: SizedBox(
            width: 110,
            height: 110,
            child: ClipOval(
              child: _bytes != null
                  ? Image.memory(
                      _bytes!,
                      key: _imageKey,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.surfaceVariant,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person,
                        size: 55,
                        color: AppColors.onSurface,
                      ),
                    ),
            ),
          ),
        ),
        if (_bytes != null)
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () async {
                  if (widget.pickedImage != null) {
                    try {
                      await FileImage(widget.pickedImage!).evict();
                    } catch (_) {}
                    try {
                      PaintingBinding.instance.imageCache.clear();
                    } catch (_) {}
                  }
                  // Clear local bytes immediately and notify parent
                  if (mounted) {
                    setState(() {
                      _bytes = null;
                      _imageKey = UniqueKey();
                    });
                  }
                  if (widget.onRemove != null) await widget.onRemove!();
                },
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.close, size: 20, color: Colors.redAccent),
                ),
              ),
            ),
          ),
      ],
    );
  }
}