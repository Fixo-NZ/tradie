import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'rates_setup_screen.dart';
import '../viewmodels/portfolio_setup_viewmodel.dart';

final portfolioSetupProvider = StateNotifierProvider<PortfolioSetupViewModel, List<String>>(
  (ref) => PortfolioSetupViewModel(),
);

class PortfolioSetupScreen extends StatelessWidget {
  const PortfolioSetupScreen({super.key});

  void _onContinue(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RatesSetupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text('Create Profile', style: AppTextStyles.appBarTitle.copyWith(color: Colors.black)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ContinueFloatingButton(onPressed: () => _onContinue(context)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.spacing8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar (4 of 6 steps)
              LinearProgressIndicator(value: 4 / 6, minHeight: 4, color: const Color.fromRGBO(9, 12, 155, 1.0),backgroundColor: const Color(0xFFDDE9FF)),
              const SizedBox(height: AppDimensions.spacing16),

              Text('Your Portfolio', style: AppTextStyles.headlineSmall.copyWith(color: const Color.fromRGBO(9, 12, 155, 1.0), fontSize: 18)),
              const SizedBox(height: AppDimensions.spacing12),

              Text('Showcase Your Works', style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppDimensions.spacing12),

              // Upload area (dashed border)
              DashedContainer(
                height: 160,
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image, size: 36, color: Colors.black38),
                      const SizedBox(height: 8),
                      Text('Upload Portfolio Images', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Placeholder for image upload logic
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(9, 12, 155, 1.0)),
                        child: const Text('Upload File'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing16),

              Text('Uploaded Images', style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppDimensions.spacing8),

              Consumer(
                builder: (context, ref, child) {
                  final uploadedImages = ref.watch(portfolioSetupProvider);

                  return DashedContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(8),
                    child: uploadedImages.isEmpty
                        ? const SizedBox(height: 120, child: Center(child: Text('No images uploaded')))
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: uploadedImages.asMap().entries.map((entry) {
                              final index = entry.key;
                              final imagePath = entry.value;
                              return Stack(
                                children: [
                                  Container(
                                    width: 140,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 207, 207, 207),
                                      borderRadius: BorderRadius.circular(6),
                                      image: DecorationImage(fit: BoxFit.cover, image: AssetImage(imagePath)),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => ref.read(portfolioSetupProvider.notifier).removeImage(index),
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spacing20),
              const SizedBox(height: 80), // space for floating button
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple dashed border container used by portfolio screen
class DashedContainer extends StatelessWidget {
  final Widget? child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const DashedContainer({this.child, this.height, this.padding, this.borderRadius, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: CustomPaint(
          painter: _DashedBorderPainter(color: const Color.fromARGB(255, 182, 181, 181)),
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

