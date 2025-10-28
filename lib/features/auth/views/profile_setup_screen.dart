import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
 const ProfileSetupScreen({super.key});

 @override
 ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
 final _formKey = GlobalKey<FormState>();
 final _firstNameController = TextEditingController();
 final _lastNameController = TextEditingController();
 final _emailController = TextEditingController();
 final _phoneController = TextEditingController(text: '+64');
 final _businessController = TextEditingController();
 final _bioController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  final ProfileService _profileService = ProfileService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

 static const Color kCustomBlue = Color(0xFF0000A8);

 @override
 void dispose() {
   _firstNameController.dispose();
   _lastNameController.dispose();
   _emailController.dispose();
   _phoneController.dispose();
   _businessController.dispose();
   _bioController.dispose();
   super.dispose();
 }

 // TEMP: hard-coded token for testing only.
  static const String _testToken = '4|jO09J2Q1pjEZeCSrLojZ8n4BWsOQNymAtJE7I2Ozfe45a7eb';

 Future<void> _chooseFile() async {
   try {
     final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
     if (picked == null) {
       return;
     }

     final int bytes = await picked.length();
     const int maxBytes = 5 * 1024 * 1024; // 5 MB
     if (bytes > maxBytes) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Image must be 5MB or smaller')),
       );
       return;
     }

     setState(() {
       _pickedImage = File(picked.path);
     });

    // Optionally upload immediately when chosen:
      // await _uploadPickedImage(); // (optional)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
 }

Future<void> _uploadPickedImage() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No image selected')));
      return;
    }

    String? token;
    try {
      token = await _secureStorage.read(key: 'access_token');
    } catch (_) {
      token = null;
    }
    // fallback to hardcoded test token for immediate testing:
    token ??= _testToken;

    try {
      final resp = await _profileService.uploadAvatar(_pickedImage!, token: token);
      if (resp.statusCode != null && resp.statusCode! >= 200 && resp.statusCode! < 300) {
        final avatarUrl = resp.data['avatar_url'] ?? resp.data['avatar_url'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture uploaded successfully')),
        );
        // Optionally update your UI or local profile data with avatarUrl
        print('avatarUrl: $avatarUrl');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${resp.statusCode}')));
        print('Upload error body: ${resp.data}');
      }
    } catch (e, st) {
      print('Upload exception: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

 InputDecoration _inputDecoration(String label) {
   return InputDecoration(
     labelText: label,
     filled: true,
     fillColor: Colors.white,
     contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
     enabledBorder: OutlineInputBorder(
       borderSide: BorderSide(color: AppColors.surfaceVariant),
       borderRadius: BorderRadius.circular(8),
     ),
     focusedBorder: OutlineInputBorder(
       borderSide: BorderSide(color: kCustomBlue, width: 1.5),
       borderRadius: BorderRadius.circular(8),
     ),
   );
 }

 void _onContinue() {
    // keep form validation if you want
    if (_formKey.currentState?.validate() ?? false) {
      // First, upload the selected image (if any), then proceed.
      // We intentionally don't ask the user — we just try to upload.
      _uploadPickedImage();
      // After successful upload you can navigate or call other endpoints to save other profile fields.
    } else {
      // still try to upload even if user didn't fill all fields? up to you:
      _uploadPickedImage();
    }
  }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.white,
     appBar: AppBar(
       backgroundColor: Colors.white,
       elevation: 0,
       leading: IconButton(
         icon: const Icon(Icons.arrow_back, color: Colors.black),
         onPressed: () => Navigator.of(context).maybePop(),
       ),
       title: Text(
         'Create Profile',
         style: AppTextStyles.appBarTitle.copyWith(color: Colors.black),
       ),
     ),
     body: SafeArea(
       child: Padding(
         padding: const EdgeInsets.symmetric(
           horizontal: AppDimensions.paddingLarge,
           vertical: AppDimensions.spacing8,
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             LinearProgressIndicator(
               value: 0.25,
               minHeight: 4,
               color: kCustomBlue,
             ),
             const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Basic Information',
              style: AppTextStyles.headlineSmall.copyWith(color: kCustomBlue, fontSize: 18),
            ),
             const SizedBox(height: AppDimensions.spacing12),

             Expanded(
               child: Form(
                 key: _formKey,
                 child: SingleChildScrollView(
                   physics: const NeverScrollableScrollPhysics(),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       TextFormField(
                         controller: _firstNameController,
                         decoration: _inputDecoration('First Name *'),
                         validator: (v) => (v == null || v.trim().isEmpty)
                             ? 'Please enter first name'
                             : null,
                       ),
                       const SizedBox(height: 8),

                       TextFormField(
                         controller: _lastNameController,
                         decoration: _inputDecoration('Last Name *'),
                         validator: (v) => (v == null || v.trim().isEmpty)
                             ? 'Please enter last name'
                             : null,
                       ),
                       const SizedBox(height: 8),

                       TextFormField(
                         controller: _emailController,
                         keyboardType: TextInputType.emailAddress,
                         decoration: _inputDecoration('Email *'),
                         validator: (v) {
                           if (v == null || v.trim().isEmpty) {
                             return 'Please enter email';
                           }
                           final emailRegex = RegExp(
                               r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
                           if (!emailRegex.hasMatch(v)) {
                             return 'Enter a valid email';
                           }
                           return null;
                         },
                       ),
                       const SizedBox(height: 8),


                       TextFormField(
                         controller: _phoneController,
                         keyboardType: TextInputType.phone,
                         decoration: _inputDecoration('Phone Number *'),
                       ),
                       const SizedBox(height: 8),

                       TextFormField(
                         controller: _businessController,
                         decoration: _inputDecoration('Business Name *'),
                         validator: (v) => (v == null || v.trim().isEmpty)
                             ? 'Please enter business name'
                             : null,
                       ),
                       const SizedBox(height: 8),

                       TextFormField(
                         controller: _bioController,
                         decoration: _inputDecoration('Professional Bio'),
                         maxLines: 3,
                       ),
                       const SizedBox(height: 12),

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
                                     backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                                     child: _pickedImage == null
                                         ? const Icon(
                                             Icons.person,
                                             size: 55,
                                             color: AppColors.onSurface,
                                           )
                                         : null,
                                   ),
                                 ),
                                 if (_pickedImage != null)
                                   Positioned(
                                     top: 0,
                                     right: 0,
                                     child: GestureDetector(
                                       onTap: () {
                                         setState(() {
                                           _pickedImage = null;
                                         });
                                       },
                                       child: Container(
                                         decoration: BoxDecoration(
                                           color: Colors.white,
                                           shape: BoxShape.circle,
                                           boxShadow: [
                                             BoxShadow(
                                               color: Colors.black12,
                                               blurRadius: 4,
                                             ),
                                           ],
                                         ),
                                         padding: const EdgeInsets.all(4),
                                         child: const Icon(Icons.close, size: 20, color: Colors.redAccent),
                                       ),
                                     ),
                                   ),
                               ],
                             ),
                             const SizedBox(width: 20),
                             // Text and button
                             Expanded(
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   SizedBox(
                                     width: 130,
                                     height: 38,
                                     child: ElevatedButton.icon(
                                       onPressed: _chooseFile,
                                       icon: const Icon(Icons.upload_file,
                                           size: 16),
                                       label: const Text(
                                         'Choose File',
                                         style: TextStyle(
                                             fontSize: 13,
                                             fontWeight: FontWeight.w500),
                                       ),
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: kCustomBlue,
                                         foregroundColor: Colors.white,
                                         shape: RoundedRectangleBorder(
                                           borderRadius:
                                               BorderRadius.circular(6),
                                         ),
                                         padding: const EdgeInsets.symmetric(
                                             horizontal: 8, vertical: 6),
                                       ),
                                     ),
                                   ),
                                   const SizedBox(height: 6),
                                   Text(
                                     'JPG, PNG, GIF, max of 5mb',
                                     style: AppTextStyles.bodySmall.copyWith(
                                       color: AppColors.onSurfaceVariant,
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
             ),

             Align(
               alignment: Alignment.centerRight,
               child: SizedBox(
                 width: 130,
                 height: 48,
                 child: ElevatedButton(
                   onPressed: _onContinue,
                   style: ElevatedButton.styleFrom(
                     shape: const StadiumBorder(),
                     backgroundColor: kCustomBlue,
                     foregroundColor: Colors.white,
                   ),
                   child: const Text(
                     'Continue',
                     style:
                         TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                   ),
                 ),
               ),
             ),
             const SizedBox(height: 8),
           ],
         ),
       ),
     ),
   );
 }
}

