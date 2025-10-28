import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'done_screen.dart';
import '../viewmodels/rates_setup_viewmodel.dart';

final ratesSetupProvider = StateNotifierProvider<RatesSetupViewModel, RatesSetupState>(
  (ref) => RatesSetupViewModel(),
);

class RatesSetupScreen extends ConsumerWidget {
  const RatesSetupScreen({super.key});

  void _onContinue(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DoneScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(ratesSetupProvider.notifier);
    final state = ref.watch(ratesSetupProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'Create Profile',
          style:
              AppTextStyles.appBarTitle.copyWith(color: AppColors.onSurface),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          ContinueFloatingButton(onPressed: () => _onContinue(context), width: 150, height: 48),
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
                value: 5 / 6,
                minHeight: 4,
                color: const Color.fromRGBO(9, 12, 155, 1.0),
                backgroundColor: const Color(0xFFDDE9FF),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              Text(
                'Your Portfolio',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: const Color.fromRGBO(9, 12, 155, 1.0), fontSize: 18),
              ),
              const SizedBox(height: AppDimensions.spacing12),

              Text(
                'Your Rates',
                style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Setup your rates for your services',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              Text(
                'How do you prefer to charge?',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppDimensions.spacing8),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _ChargeModeButton(
                    label: 'Hourly',
                    icon: Icons.access_time,
                    selected: state.chargeMode == 0,
                    onTap: () => viewModel.updateChargeMode(0),
                    selectedColor: const Color.fromRGBO(9, 12, 155, 1.0),
                  ),
                  const SizedBox(width: 12),
                  _ChargeModeButton(
                    label: 'Fixed Price',
                    icon: Icons.payment,
                    selected: state.chargeMode == 1,
                    onTap: () => viewModel.updateChargeMode(1),
                    selectedColor: const Color.fromRGBO(9, 12, 155, 1.0),
                  ),
                  const SizedBox(width: 12),
                  _ChargeModeButton(
                    label: 'Both',
                    icon: Icons.grid_view,
                    selected: state.chargeMode == 2,
                    onTap: () => viewModel.updateChargeMode(2),
                    selectedColor: const Color.fromRGBO(9, 12, 155, 1.0),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),

              Text('Standard Rate',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppDimensions.spacing8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: state.hourlyRate,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixText: '\$ ',
                        hintText: '0.00',
                        hintStyle:
                            const TextStyle(color: Color(0xFFBDBDBD)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                      ),
                      onChanged: viewModel.updateHourlyRate,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),

                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<int>(
                      value: state.minimumHours,
                      items: [1, 2, 3, 4, 5].map((e) {
                        return DropdownMenuItem<int>(
                          value: e,
                          child: Text(
                            '$e hour${e > 1 ? 's' : ''}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        viewModel.updateMinimumHours(value ?? 1);
                      },
                      dropdownColor: Colors.white,
                      iconEnabledColor: const Color.fromRGBO(9, 12, 155, 1.0),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacing12),
              const Text(
                'Description (Optional)',
                style: TextStyle(
                    fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              TextFormField(
                initialValue: state.hourlyRate,
                minLines: 5,
                maxLines: 8,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  hintText:
                      "Describe what's included in your standard rate",
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: viewModel.updateHourlyRate,
              ),

              const SizedBox(height: AppDimensions.spacing12),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE6E6E6)),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.surface,
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  title: Text('After Hours Rate',
                      style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface)),
                  subtitle: Text('When working overtime charge a fee',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  trailing: Checkbox(
                    value: state.afterHours,
                    onChanged: viewModel.toggleAfterHours,
                    activeColor: const Color.fromRGBO(9, 12, 155, 1.0),
                    checkColor: AppColors.onPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing12),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE6E6E6)),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.surface,
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  title: Text('Charge A Service/Call-out Fee',
                      style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface)),
                  subtitle: Text(
                      'Charge customers when contacting you or ask question',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  trailing: Checkbox(
                    value: state.callOut,
                    onChanged: viewModel.toggleCallOut,
                    activeColor: const Color.fromRGBO(9, 12, 155, 1.0),
                    checkColor: AppColors.onPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing20),
              const SizedBox(height: 80), // space for button
            ],
          ),
        ),
      ),
    );
  }
}

// Charge mode button widget
class _ChargeModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _ChargeModeButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? selectedColor : const Color(0xFFCACACA);
    final bg = selected ? selectedColor : Colors.white;
    final textColor = selected ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color:
                    selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: textColor),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: textColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// Final screen after setup
class DoneSetupScreen extends StatelessWidget {
  const DoneSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'Create Profile',
          style:
              AppTextStyles.appBarTitle.copyWith(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(9, 12, 155, 1.0)),
                child: const Icon(Icons.check, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 24),
              Text('All set!',
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 20)),
              const SizedBox(height: 8),
              Text('Your profile setup is complete.',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: Colors.black54)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(9, 12, 155, 1.0)),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
