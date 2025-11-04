import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'confirmation_screen.dart';
import '../viewmodels/done_viewmodel.dart';

// ✅ Riverpod provider that connects the ViewModel (logic) to the UI (this screen)
final doneProvider = StateNotifierProvider<DoneViewModel, DoneState>(
  (ref) => DoneViewModel(),
);

class DoneScreen extends ConsumerWidget {
  const DoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the ViewModel (logic controller)
    final viewModel = ref.read(doneProvider.notifier);

    // Watch the current state (data: name, email, skills, etc.)
    final state = ref.watch(doneProvider);

    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar: The top navigation bar with a back button and title
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(), // Custom back button widget
        title: Text(
          'Create Profile',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.black),
        ),
      ),

      // Floating button at the bottom right
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ContinueFloatingButton(
        onPressed: () {
          // When pressed → navigate to ConfirmationScreen
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
          );
        },
        backgroundColor: AppColors.tradieBlue,
      ),

      // Screen body content
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar showing completion progress
              LinearProgressIndicator(
                value: 1.0, // Fully completed
                minHeight: 4,
                color: const Color.fromRGBO(9, 12, 155, 1.0),
                backgroundColor: AppColors.surfaceVariant,
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Profile picture section (uses DoneState.avatar returned by the profile API)
              Center(
                child: Builder(builder: (context) {
                  // The done state is already being watched above into `state` variable.
                  final avatarPath = state.avatar;

                  if (avatarPath != null && avatarPath.isNotEmpty) {
                    final url = avatarPath.startsWith('http')
                        ? avatarPath
                        : '${ApiConstants.baseUrl}$avatarPath';
                    final cacheBusted = '$url?t=${DateTime.now().millisecondsSinceEpoch}';

                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surfaceVariant,
                      backgroundImage: NetworkImage(cacheBusted),
                    );
                  }

                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white70,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // User's name and email
              Center(
                child: Column(
                  children: [
                    if (state.isLoading)
                      // Show loading indicator while fetching data
                      const CircularProgressIndicator()
                    else if (state.error != null)
                      // Show error message if fetching failed
                      Text(
                        state.error!,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      )
                    else ...[
                      // Show user's full name
                      Text(
                        '${state.firstName ?? ''} ${state.lastName ?? ''}'.trim(),
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing8),

                      // Show email
                      Text(
                        state.email ?? '',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),

              // Edit Profile button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                  },
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

              // Tabs (Portfolio, Credentials, Review)
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
                  // Section title
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

                  // User bio text box
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    child: Text(
                      state.bio ?? 'No bio available',
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
                  // Section title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12, vertical: AppDimensions.spacing8),
                    decoration: BoxDecoration(
                      color: Colors.white, 
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

                  // Displays a list of skill chips (tags)
                  Wrap(
                    spacing: AppDimensions.spacing8,
                    runSpacing: AppDimensions.spacing8,
                    children: state.skills.isEmpty
                        ? [const Text('No skills added yet')]
                        : state.skills.map((skill) => _SkillChip(label: skill)).toList(),
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

//  Custom Tab Button widget (used for Portfolio / Credentials / Review)
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
            // Underline indicator for selected tab
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

// Skill chip widget
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
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w400, 
        ),
      ),
    );
  }
}
