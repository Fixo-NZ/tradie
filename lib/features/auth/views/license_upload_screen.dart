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
  static const double fixedContainerHeight = 160.0; // Defined fixed height

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
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SkillsSetupScreen()),
      );
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
                height: fixedContainerHeight, // Apply fixed height
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.all(12),
                child: state.licenseFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.description_outlined,
                                size: 36, color: Colors.black38),
                            const SizedBox(height: 8),
                            Text(
                              'Upload License Documents',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _pickLicenseFile(context, ref),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kCustomBlue),
                              child: const Text('Upload File'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView( // Allow scrolling when files are present
                        child: Wrap(
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
                      ),
              ),

              // "Add More" button is placed outside the dashed container
              if (state.licenseFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _pickLicenseFile(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add More'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kCustomBlue),
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
                height: fixedContainerHeight, // Apply fixed height
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.all(12),
                child: state.idFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.image_not_supported_outlined,
                                size: 36, color: Colors.black38),
                            const SizedBox(height: 8),
                            Text(
                              'Upload Valid ID Images',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
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
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _pickIdFile(context, ref),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kCustomBlue),
                              child: const Text('Upload File'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView( // Allow scrolling when files are present
                        child: Wrap(
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
                      ),
              ),

              // "Add More" button is placed outside the dashed container
              if (state.idFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _pickIdFile(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add More'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kCustomBlue),
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