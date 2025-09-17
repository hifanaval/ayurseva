import 'package:ayurseva/components/custom_dropdown.dart';
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:ayurseva/screens/registration_screen/registration_screen.dart';
import 'package:ayurseva/screens/registration_screen/provider/registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TreatmentSelectionBottomSheet extends StatefulWidget {
  final List<Treatment> selectedTreatments;
  final Function(List<Treatment>) onSave;

  const TreatmentSelectionBottomSheet({
    super.key,
    required this.selectedTreatments,
    required this.onSave,
  }) ;

  // Static method to show the bottom sheet
  static void show(
    BuildContext context, {
    required List<Treatment> selectedTreatments,
    required Function(List<Treatment>) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TreatmentSelectionBottomSheet(
        selectedTreatments: selectedTreatments,
        onSave: onSave,
      ),
    );
  }

  @override
  State<TreatmentSelectionBottomSheet> createState() =>
      _TreatmentSelectionBottomSheetState();
}

class _TreatmentSelectionBottomSheetState
    extends State<TreatmentSelectionBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Initialize treatment selection in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistrationProvider>().initializeTreatmentSelection();
    });
  }

  void _incrementCount(bool isMale) {
    context.read<RegistrationProvider>().incrementCount(isMale);
  }

  void _decrementCount(bool isMale) {
    context.read<RegistrationProvider>().decrementCount(isMale);
  }

  void _saveTreatment() {
    final provider = context.read<RegistrationProvider>();
    provider.saveTreatment();
    widget.onSave(provider.selectedTreatments);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, provider, child) {
        return Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: ColorClass.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ColorClass.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Choose Treatment',
                      style: TextStyleClass.heading3(ColorClass.primaryText),
                    ),
                    const SizedBox(height: 20),

                    // Treatment Dropdown
                    CustomDropdown.field(
                      hintText: 'Choose your treatment',
                      labelText: 'Treatment',
                      value: provider.availableTreatments.contains(provider.selectedTreatment) 
                          ? provider.selectedTreatment 
                          : null,
                      items: provider.availableTreatments,
                      onChanged: (value) {
                        provider.updateSelectedTreatment(value);
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a treatment';
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Add Patients Section
                    Text(
                      'Add Patients',
                      style: TextStyleClass.heading4(ColorClass.primaryText),
                    ),
                    const SizedBox(height: 16),

                    // Male Counter
                    _buildCounterRow('Male', provider.maleCount, true),
                    const SizedBox(height: 16),

                    // Female Counter
                    _buildCounterRow('Female', provider.femaleCount, false),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTreatment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorClass.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyleClass.buttonLarge(ColorClass.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCounterRow(String label, int count, bool isMale) {
    return Row(
      children: [
        // Label
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ColorClass.grey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorClass.black.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              label,
              style: TextStyleClass.buttonLarge(ColorClass.primaryText),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Decrease Button
        GestureDetector(
          onTap: () => _decrementCount(isMale),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColorClass.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 16),

        // Count Display
        Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: ColorClass.grey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorClass.black.withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyleClass.buttonLarge(ColorClass.primaryText),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Increase Button
        GestureDetector(
          onTap: () => _incrementCount(isMale),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColorClass.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}