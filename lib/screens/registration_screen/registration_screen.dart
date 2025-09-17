import 'package:ayurseva/components/custom_button.dart';
import 'package:ayurseva/components/custom_dropdown.dart';
import 'package:ayurseva/components/custom_textfield.dart';
import 'package:ayurseva/screens/registration_screen/models/selected_treatment_model.dart';
import 'package:ayurseva/screens/registration_screen/widgets/treatment_selection_bottomsheet.dart';
import 'package:ayurseva/screens/registration_screen/provider/registration_provider.dart';
import 'package:ayurseva/screens/registration_screen/provider/branch_provider.dart';
import 'package:ayurseva/screens/registration_screen/provider/treatment_type_provider.dart';
import 'package:ayurseva/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:provider/provider.dart';




// Main Registration Screen
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  Future<void> _fetchInitialData() async {
    final branchProvider = Provider.of<BranchProvider>(context, listen: false);
    final treatmentProvider = Provider.of<TreatmentTypeProvider>(
      context,
      listen: false,
    );

    try {
      // Fetch branch data directly
      await branchProvider.fetchBranchData(context);

      // Fetch treatment data directly
      await treatmentProvider.fetchTreatmentData(context);
    } catch (e) {
      debugPrint('RegistrationScreen: Error fetching initial data - $e');
    }
  }

  void _showTreatmentModal(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder:
          (context) => TreatmentSelectionBottomSheet(
            selectedTreatments: registrationProvider.selectedTreatments,
            onSave: (treatments) {
              registrationProvider.updateSelectedTreatments(treatments);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Consumer2<RegistrationProvider, TreatmentTypeProvider>(
          builder: (context, registrationProvider, treatmentProvider, child) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: ColorClass.primaryText,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Register',
                      style: TextStyleClass.heading2(ColorClass.primaryText),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: registrationProvider.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          CustomTextFormField(
                            controller: registrationProvider.nameController,
                            hintText: 'Enter your full name',
                            labelText: 'Name',
                            validator: registrationProvider.validateName,
                          ),
                          const SizedBox(height: 20),

                          // WhatsApp Number
                          CustomTextFormField(
                            controller: registrationProvider.whatsappController,
                            hintText: 'Enter your WhatsApp number',
                            labelText: 'WhatsApp Number',
                            keyboardType: TextInputType.phone,
                            validator: registrationProvider.validateWhatsApp,
                          ),
                          const SizedBox(height: 20),

                          // Address
                          CustomTextFormField(
                            controller: registrationProvider.addressController,
                            hintText: 'Enter your full address',
                            labelText: 'Address',
                            maxLines: 2,
                            validator: registrationProvider.validateAddress,
                          ),
                          const SizedBox(height: 20),

                          // Location
                          CustomDropdown.field(
                            hintText: 'Choose your location',
                            labelText: 'Location',
                            value: registrationProvider.selectedLocation,
                            items: registrationProvider.locations,
                            onChanged: registrationProvider.updateLocation,
                            validator: registrationProvider.validateLocation,
                          ),
                          const SizedBox(height: 20),

                          Consumer<BranchProvider>(
                            builder: (context, branchProvider, child) {
                              return CustomDropdown.field(
                                hintText: 'Select the branch',
                                labelText: 'Branch',
                                value: registrationProvider.selectedBranch,
                                items: branchProvider.getAllBranchNames(),
                                onChanged: registrationProvider.updateBranch,
                                validator: registrationProvider.validateBranch,
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Treatments Section
                          Text(
                            'Treatments',
                            style: TextStyleClass.bodyLarge(
                              ColorClass.primaryText,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Selected Treatments List
                          ...registrationProvider.selectedTreatments.asMap().entries.map((
                            entry,
                          ) {
                            int index = entry.key;
                            Treatment treatment = entry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ColorClass.grey.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${index + 1}. ',
                                              style: TextStyleClass.buttonLarge(
                                                ColorClass.primaryText,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                treatment.name,
                                                style:
                                                    TextStyleClass.buttonLarge(
                                                      ColorClass.primaryText,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: ColorClass.primaryColor
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Male ${treatment.maleCount}',
                                                style: TextStyleClass.bodySmall(
                                                  ColorClass.primaryColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: ColorClass.primaryColor
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Female ${treatment.femaleCount}',
                                                style: TextStyleClass.bodySmall(
                                                  ColorClass.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            () => registrationProvider
                                                .removeTreatment(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(
                                              alpha: 0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap:
                                            () => _showTreatmentModal(context),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: ColorClass.primaryColor
                                                .withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.edit,
                                            color: ColorClass.primaryColor,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),

                          // Add Treatments Button
                          GestureDetector(
                            onTap: () => _showTreatmentModal(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: ColorClass.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '+ Add Treatments',
                                  style: TextStyleClass.buttonLarge(
                                    ColorClass.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Total Amount
                          CustomTextFormField(
                            controller:
                                registrationProvider.totalAmountController,
                            hintText: 'Enter total amount',
                            labelText: 'Total Amount',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          // Discount Amount
                          CustomTextFormField(
                            controller:
                                registrationProvider.discountAmountController,
                            hintText: 'Enter discount amount',
                            labelText: 'Discount Amount',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          // Payment Option
                          Text(
                            'Payment Option',
                            style: TextStyleClass.bodyLarge(
                              ColorClass.primaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildRadioOption('Cash', registrationProvider),
                              const SizedBox(width: 20),
                              _buildRadioOption('Card', registrationProvider),
                              const SizedBox(width: 20),
                              _buildRadioOption('UPI', registrationProvider),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Advance Amount
                          CustomTextFormField(
                            controller:
                                registrationProvider.advanceAmountController,
                            hintText: 'Enter advance amount',
                            labelText: 'Advance Amount',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          // Balance Amount
                          CustomTextFormField(
                            controller:
                                registrationProvider.balanceAmountController,
                            hintText: 'Enter balance amount',
                            labelText: 'Balance Amount',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          // Treatment Date
                          GestureDetector(
                            onTap: () => _showDatePicker(context, registrationProvider),
                            child: AbsorbPointer(
                              child: CustomTextFormField(
                                controller:
                                    registrationProvider
                                        .treatmentDateController,
                                hintText: 'Select treatment date',
                                labelText: 'Treatment Date',
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  color: ColorClass.primaryColor,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select treatment date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Treatment Time
                          Text(
                            'Treatment Time',
                            style: TextStyleClass.bodyLarge(
                              ColorClass.primaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _showTimePicker(context, registrationProvider),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorClass.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: ColorClass.primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      registrationProvider.selectedDateTime != null
                                          ? AppUtils.formatTreatmentTime(
                                              registrationProvider.selectedDateTime!,
                                            )
                                          : 'Select Time',
                                      style: TextStyleClass.poppinsSemiBold(
                                        16,
                                        registrationProvider.selectedDateTime != null
                                            ? ColorClass.primaryText
                                            : ColorClass.grey.withValues(
                                                alpha: 0.5,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: ColorClass.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                // Save Button (matching treatment list screen style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomButton(
                    text: 'Save',
                    onPressed: () => registrationProvider.registerPatient(
                      context: context,
                      treatmentProvider: treatmentProvider,
                    ),
                    isLoading: registrationProvider.isLoading,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRadioOption(String option, RegistrationProvider provider) {
    return Row(
      children: [
        Radio<String>(
          value: option,
          groupValue: provider.selectedPaymentOption,
          onChanged: (value) {
            provider.updatePaymentOption(value!);
          },
          activeColor: ColorClass.primaryColor,
        ),
        Text(option, style: TextStyleClass.bodyMedium(ColorClass.primaryText)),
      ],
    );
  }

  /// Show date picker for treatment date selection
  Future<void> _showDatePicker(
    BuildContext context,
    RegistrationProvider registrationProvider,
  ) async {
    debugPrint('RegistrationScreen: Showing date picker');
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: registrationProvider.selectedTreatmentDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Can't select past dates
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // 1 year from now
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorClass.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ColorClass.primaryText,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      debugPrint('RegistrationScreen: Date selected - ${AppUtils.formatDate(pickedDate)}');
      registrationProvider.updateTreatmentDate(pickedDate);
    } else {
      debugPrint('RegistrationScreen: Date picker cancelled');
    }
  }

  /// Show time picker for treatment time selection
  void _showTimePicker(
    BuildContext context,
    RegistrationProvider registrationProvider,
  ) {
    debugPrint('RegistrationScreen: Showing time picker');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        height: 280,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    debugPrint('RegistrationScreen: Time picker cancelled');
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyleClass.poppinsSemiBold(
                      16,
                      ColorClass.grey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Text(
                  'Select Time',
                  style: TextStyleClass.poppinsSemiBold(
                    18,
                    ColorClass.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    debugPrint('RegistrationScreen: Time picker done');
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Done',
                    style: TextStyleClass.poppinsSemiBold(
                      16,
                      ColorClass.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false, // Change to true for 24-hour format
                onDateTimeChanged: (DateTime dateTime) {
                  debugPrint('RegistrationScreen: Time selected - ${AppUtils.formatTreatmentTime(dateTime)}');
                  registrationProvider.updateSelectedDateTime(dateTime);
                },
                initialDateTime: DateTime.now(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
