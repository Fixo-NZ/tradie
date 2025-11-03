import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'done_screen.dart';
import '../viewmodels/rates_setup_viewmodel.dart';

final ratesSetupProvider =
    StateNotifierProvider<RatesSetupViewModel, RatesSetupState>(
  (ref) => RatesSetupViewModel(),
);

class RatesSetupScreen extends ConsumerWidget {
  const RatesSetupScreen({super.key});

  // ✅ Handles save + navigation logic safely
  void _onContinue(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(ratesSetupProvider.notifier);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Saving your rates..."),
        duration: Duration(seconds: 1),
      ),
    );

    final success = await viewModel.saveRates();

    if (success) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const DoneScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to save rates')),
      );
    }
  }


  List<Map<String, String>> _generateTimeIntervals() {
    final intervals = <Map<String, String>>[];
    for (int hour = 0; hour <= 24; hour++) {
      if (hour != 0) {
        intervals.add({
          'label': '$hour ${hour == 1 ? 'hour' : 'hours'}',
          'value': '${hour.toString().padLeft(2, '0')}:00',
        });
      }
      if (hour < 24) {
        intervals.add({
          'label': '$hour ${hour == 1 ? 'hour' : 'hours'} 30 mins',
          'value': '${hour.toString().padLeft(2, '0')}:30',
        });
      }
    }
    return intervals;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(ratesSetupProvider.notifier);
    final state = ref.watch(ratesSetupProvider);

    final timeOptions = _generateTimeIntervals();

    // Make sure dropdownValue is always safe
    final dropdownValue = timeOptions
        .firstWhere(
          (element) => element['value'] == state.minimumHoursString,
          orElse: () => timeOptions.first,
        )['value'];

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
      floatingActionButton: ContinueFloatingButton(
        onPressed: () => _onContinue(context, ref),
        width: 150,
        height: 48,
      ),
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

              // ====== HEADER ======
              Text(
                'Your Portfolio',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: const Color.fromRGBO(9, 12, 155, 1.0),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Text(
                'Your Rates',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Setup your rates for your services',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // ====== CHARGE MODE ======
              Text(
                'How do you prefer to charge?',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.onSurface),
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

              // ====== STANDARD RATE & MINIMUM HOURS DROPDOWN ======
              Text(
                'Standard Rate & Minimum Hours',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: state.hourlyRate,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        hintText: "Enter rate",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                      ),
                      onChanged: viewModel.updateHourlyRate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue,
                      items: timeOptions.map((time) {
                        return DropdownMenuItem<String>(
                          value: time['value'],
                          child: Text(
                            time['label']!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.updateMinimumHoursString(value);
                        }
                      },
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.tradieBlue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: AppColors.onSurface),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing12),

              // ====== DESCRIPTION ======
              const Text(
                'Description (Optional)',
                style:
                    TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: state.description,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  hintText: "Describe what's included in your standard rate",
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: viewModel.updateDescription,
              ),
              const SizedBox(height: AppDimensions.spacing12),

              // ====== AFTER HOURS ======
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE6E6E6)),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.surface,
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  title: Text(
                    'After Hours Rate',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'When working overtime charge a fee',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  trailing: Checkbox(
                    value: state.afterHours,
                    onChanged: viewModel.toggleAfterHours,
                    activeColor: const Color.fromRGBO(9, 12, 155, 1.0),
                    checkColor: AppColors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing12),

              // ====== CALL OUT FEE ======
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE6E6E6)),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.surface,
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  title: Text(
                    'Charge A Service/Call-out Fee',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Charge customers when contacting you or asking questions',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  trailing: Checkbox(
                    value: state.callOut,
                    onChanged: viewModel.toggleCallOut,
                    activeColor: const Color.fromRGBO(9, 12, 155, 1.0),
                    checkColor: AppColors.onPrimary,
                  ),
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

class _ChargeModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _ChargeModeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

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
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style:
                  TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
