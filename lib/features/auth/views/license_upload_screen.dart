import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'skills_setup_screen.dart';
import '../viewmodels/license_upload_viewmodel.dart';

class LicenseUploadScreen extends ConsumerWidget {
  const LicenseUploadScreen({super.key});

  static const Color kCustomBlue = Color.fromRGBO(9, 12, 155, 1.0);
  static const double defaultContainerHeight = 200.0; // Default height for empty state

  Future<void> _pickLicenseFile(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      ref.read(licenseUploadViewModelProvider.notifier)
          .addLicenseFile(picked.name, picked.path);
    }
  }

  Future<void> _pickIdFile(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      ref.read(licenseUploadViewModelProvider.notifier)
          .addIdFile(picked.name, picked.path);
    }
  }

  Future<void> _onContinue(BuildContext context, WidgetRef ref) async {
    final vm = ref.read(licenseUploadViewModelProvider.notifier);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Submit files to backend
    final success = await vm.submitLicenseFiles();

    if (context.mounted) Navigator.pop(context); // close loader

    if (success) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SkillsSetupScreen()),
        );
      }
    } else {
      final state = ref.read(licenseUploadViewModelProvider);
      final errorMsg = state.errorMessage ?? 'Failed to upload files';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(licenseUploadViewModelProvider);
    final vm = ref.read(licenseUploadViewModelProvider.notifier);

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
      floatingActionButton: ContinueFloatingButton(
        onPressed: () => _onContinue(context, ref),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.spacing8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: 2 / 6,
                minHeight: 4,
                color: kCustomBlue,
                backgroundColor: const Color(0xFFDDE9FF),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              Text(
                'Your Licenses',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: kCustomBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Upload Files',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Attach necessary documents for verification.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              /// ================= LICENSES ======================
              Text(
                'Licenses & Certificates',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              DashedContainer(
                height: state.licenseFiles.isEmpty ? defaultContainerHeight : null,
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity, // Full width
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.licenseFiles.isEmpty)
                        // Empty state content
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.description_outlined,
                                  size: 48, color: Colors.black38),
                              const SizedBox(height: 12),
                              Text(
                                'Upload License Documents',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // Images display
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.licenseFiles
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final file = entry.value;

                            return Stack(
                              children: [
                                Container(
                                  width: 140,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 207, 207, 207),
                                    borderRadius: BorderRadius.circular(6),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(File(file.path)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () =>
                                        vm.removeLicenseFile(index),
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      
                      // Upload button always at bottom center inside dashed border
                      if (state.licenseFiles.isNotEmpty) const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _pickLicenseFile(context, ref),
                        icon: Icon(state.licenseFiles.isEmpty ? Icons.upload_file : Icons.add),
                        label: Text(state.licenseFiles.isEmpty ? 'Upload File' : 'Add More'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kCustomBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      if (state.licenseFiles.isEmpty) const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// ================= IDs ======================
              Text(
                'IDs',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              DashedContainer(
                height: state.idFiles.isEmpty ? defaultContainerHeight : null,
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity, // Full width
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.idFiles.isEmpty)
                        // Empty state content
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image_not_supported_outlined,
                                  size: 48, color: Colors.black38),
                              const SizedBox(height: 12),
                              Text(
                                'Upload Valid ID Images',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PNG, JPG, PDF up to 10MB',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // Images display
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.idFiles
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final file = entry.value;

                            return Stack(
                              children: [
                                Container(
                                  width: 140,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 207, 207, 207),
                                    borderRadius: BorderRadius.circular(6),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(File(file.path)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => vm.removeIdFile(index),
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      
                      // Upload button always at bottom center inside dashed border
                      if (state.idFiles.isNotEmpty) const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _pickIdFile(context, ref),
                        icon: Icon(state.idFiles.isEmpty ? Icons.upload_file : Icons.add),
                        label: Text(state.idFiles.isEmpty ? 'Upload File' : 'Add More'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kCustomBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      if (state.idFiles.isEmpty) const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======== MATCHED DASHED BORDER CONTAINER (No Changes Needed Here) =========

class DashedContainer extends StatelessWidget {
  final Widget? child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const DashedContainer({
    this.child,
    this.height,
    this.padding,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color.fromARGB(255, 182, 181, 181),
          ),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashWidth = 6.0;
    const dashSpace = 6.0;

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}