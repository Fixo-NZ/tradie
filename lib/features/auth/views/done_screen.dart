import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'confirmation_screen.dart';
import '../viewmodels/done_viewmodel.dart';

final doneProvider = StateNotifierProvider<DoneViewModel, DoneState>(
  (ref) => DoneViewModel(),
);

class DoneScreen extends ConsumerWidget {
  const DoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(doneProvider.notifier);
    final state = ref.watch(doneProvider);

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
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
          );
        },
        backgroundColor: AppColors.tradieBlue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: 1.0,
                minHeight: 4,
                color: const Color.fromRGBO(9, 12, 155, 1.0),
                backgroundColor: AppColors.surfaceVariant,
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Profile picture
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: AssetImage('assets/images/profile_picture.png'),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Name and email
              Center(
                child: Column(
                  children: [
                    Text(
                      'Jane Smith',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      'janesmith@example.com',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),

              // Edit Profile button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tradieBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),

              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TabButton(
                    label: 'Portfolio',
                    selected: state.selectedTabIndex == 0,
                    onTap: () => viewModel.updateSelectedTab(0),
                    underline: true,
                  ),
                  _TabButton(
                    label: 'Credentials',
                    selected: state.selectedTabIndex == 1,
                    onTap: () => viewModel.updateSelectedTab(1),
                    underline: true,
                  ),
                  _TabButton(
                    label: 'Review',
                    selected: state.selectedTabIndex == 2,
                    onTap: () => viewModel.updateSelectedTab(2),
                    underline: true,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // About Me section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12, vertical: AppDimensions.spacing8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(9, 12, 155, 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    child: Text(
                      'About Me',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: const Color.fromRGBO(9, 12, 155, 1.0),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    child: Text(
                      "I'm a mural painter passionate about transforming spaces with vibrant, meaningful artwork. With a focus on storytelling through visuals and attention to detail, I create murals that bring life to walls in businesses, homes, and public spaces. Whether bold, calming, or custom-designed, I aim to make each mural unique and impactful.",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // My Skills section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12, vertical: AppDimensions.spacing8),
                    decoration: BoxDecoration(
                      color: Colors.white, // Changed to white
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    child: Text(
                      'My Skills',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: const Color.fromRGBO(9, 12, 155, 1.0),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Wrap(
                    spacing: AppDimensions.spacing8,
                    runSpacing: AppDimensions.spacing8,
                    children: [
                      _SkillChip(label: 'Painting'),
                      _SkillChip(label: 'Wiring'),
                      _SkillChip(label: 'Cable'),
                      _SkillChip(label: 'Lighting'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool underline;

  const _TabButton({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.underline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: selected ? const Color.fromRGBO(9, 12, 155, 1.0) : AppColors.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            if (underline)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 40,
                color: selected ? const Color.fromRGBO(9, 12, 155, 1.0) : Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12, vertical: AppDimensions.spacing8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(9, 12, 155, 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: Colors.black, // Changed to black
          fontSize: 14,
          fontWeight: FontWeight.w400, // Made text lighter
        ),
      ),
    );
  }
}