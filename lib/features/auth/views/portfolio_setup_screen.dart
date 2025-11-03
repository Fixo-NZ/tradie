import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'rates_setup_screen.dart';
import '../viewmodels/portfolio_setup_viewmodel.dart';
import '../services/api_service.dart';

final portfolioSetupProvider =
    StateNotifierProvider<PortfolioSetupViewModel, List<String>>(
  (ref) => PortfolioSetupViewModel(),
);

class PortfolioSetupScreen extends ConsumerWidget {
  const PortfolioSetupScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      ref.read(portfolioSetupProvider.notifier).addImage(picked.path);
    }
  }

  Future<void> _onContinue(BuildContext context, WidgetRef ref) async {
    final uploadedImages = ref.read(portfolioSetupProvider);

    final api = ApiService();

    // Send multiple images
    for (final path in uploadedImages) {
      final file = File(path);
      final result = await api.multipartPost(
        endpoint: '/profile-setup/portfolio',
        fields: {},
        file: file,
        fileFieldName: 'portfolio_images[]', // Laravel expects array
      );

      debugPrint("Upload result: ${result['body']}");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Portfolio uploaded successfully")),
    );

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RatesSetupScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadedImages = ref.watch(portfolioSetupProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text('Create Profile',
            style:
                AppTextStyles.appBarTitle.copyWith(color: Colors.black)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          ContinueFloatingButton(onPressed: () => _onContinue(context, ref)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.spacing8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: 4 / 6,
                minHeight: 4,
                color: const Color.fromRGBO(9, 12, 155, 1.0),
                backgroundColor: const Color(0xFFDDE9FF),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              Text('Your Portfolio',
                  style: AppTextStyles.headlineSmall.copyWith(
                      color: const Color.fromRGBO(9, 12, 155, 1.0),
                      fontSize: 18)),
              const SizedBox(height: AppDimensions.spacing12),

              Text('Showcase Your Works', style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppDimensions.spacing12),

              DashedContainer(
                height: 160,
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image,
                          size: 36, color: Colors.black38),
                      const SizedBox(height: 8),
                      Text('Upload Portfolio Images',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _pickImage(context, ref),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(9, 12, 155, 1.0)),
                        child: const Text('Upload File'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing16),
              Text('Uploaded Images', style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppDimensions.spacing8),

              DashedContainer(
                padding: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(8),
                child: uploadedImages.isEmpty
                    ? const SizedBox(
                        height: 120,
                        child: Center(child: Text('No images uploaded')))
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            uploadedImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final imagePath = entry.value;
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
                                      image: FileImage(File(imagePath))),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => ref
                                      .read(portfolioSetupProvider.notifier)
                                      .removeImage(index),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle),
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

              const SizedBox(height: AppDimensions.spacing20),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashed border container (same as yours)
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
              color: const Color.fromARGB(255, 182, 181, 181)),
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
      double distance = 0.0;
      while (distance < metric.length) {
        final len = dashWidth;
        canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
