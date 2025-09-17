import 'package:ayurseva/screens/registration_screen/models/selected_treatment_model.dart';
import 'package:flutter/material.dart';
import 'package:ayurseva/screens/registration_screen/provider/treatment_type_provider.dart';
import 'package:ayurseva/constants/api_urls.dart';
import 'package:ayurseva/constants/string_class.dart';
import 'package:ayurseva/utils/shared_utils.dart';
import 'package:ayurseva/utils/app_utils.dart';
import 'package:ayurseva/screens/pdf_generator/pdf_generator_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationProvider extends ChangeNotifier {
  // Loading state
  bool isLoading = false;

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController discountAmountController =
      TextEditingController();
  final TextEditingController advanceAmountController = TextEditingController();
  final TextEditingController balanceAmountController = TextEditingController();
  final TextEditingController treatmentDateController = TextEditingController();
  final TextEditingController dateRangeController = TextEditingController();

  // Dropdown values
  String? selectedLocation;
  String? selectedBranch;
  String selectedPaymentOption = 'Cash';
  String selectedHour = '12';
  String selectedMinute = '00';
  TimeOfDay? selectedTime;
  DateTime? selectedDateTime;
  int selectedHourIndex = 0;
  int selectedMinuteIndex = 0;
  String selectedPeriod = 'AM';

  // Treatment list
  List<Treatment> selectedTreatments = [];

  // Treatment selection bottom sheet variables
  String? selectedTreatment;
  int maleCount = 0;
  int femaleCount = 0;
  late List<Treatment> treatments;

  DateTime? selectedTreatmentDate;
  DateTime? tempSelectedDate;
  DateTime? focusedDay;
  DateTimeRange? selectedDateRange;

  // Static locations
  final List<String> locations = ['Kochi,kerala', 'Kozhikode', 'Kumarakom'];

  final List<String> hours = List.generate(
    24,
    (index) => index.toString().padLeft(2, '0'),
  );
  final List<String> minutes = List.generate(
    60,
    (index) => index.toString().padLeft(2, '0'),
  );

  void updateSelectedTime(TimeOfDay time) {
    selectedTime = time;
    notifyListeners();
  }

  void updateSelectedDateTime(DateTime dateTime) {
    selectedDateTime = dateTime;

    // Update the individual time components for PDF generation
    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    selectedHour = timeOfDay.hourOfPeriod.toString().padLeft(2, '0');
    selectedMinute = timeOfDay.minute.toString().padLeft(2, '0');
    selectedPeriod = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

    debugPrint(
      'RegistrationProvider: Updated time - $selectedHour:$selectedMinute $selectedPeriod',
    );
    notifyListeners();
  }

  void updateTimeFromWheels() {
    final hour = selectedHourIndex + 1;
    final minute = selectedMinuteIndex;
    final time = TimeOfDay(
      hour:
          selectedPeriod == 'AM'
              ? (hour == 12 ? 0 : hour)
              : (hour == 12 ? 12 : hour + 12),
      minute: minute,
    );
    selectedTime = time;
    notifyListeners();
  }

  void updateTreatmentDate(DateTime date) {
    selectedTreatmentDate = date;
    treatmentDateController.text = AppUtils.formatDate(date);
    notifyListeners();
  }

  void updateCalendarSelection(DateTime selectedDay, DateTime focusedDay) {
    selectedTreatmentDate = selectedDay;
    this.focusedDay = focusedDay;
    notifyListeners();
  }

  void confirmDateSelection() {
    if (selectedTreatmentDate != null) {
      treatmentDateController.text = AppUtils.formatDate(
        selectedTreatmentDate!,
      );
    }
    notifyListeners();
  }

  void updateDateRange(DateTimeRange range) {
    selectedDateRange = range;
    dateRangeController.text =
        '${AppUtils.formatDate(range.start)} - ${AppUtils.formatDate(range.end)}';
    notifyListeners();
  }

  // Validation methods
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateSelection(String? value, String fieldName) {
    if (value == null) {
      return 'Please select a $fieldName';
    }
    return null;
  }

  // Convenience methods for specific fields
  String? validateName(String? value) => validateRequired(value, 'Name');
  String? validateWhatsApp(String? value) =>
      validateRequired(value, 'WhatsApp number');
  String? validateAddress(String? value) => validateRequired(value, 'Address');
  String? validateLocation(String? value) =>
      validateSelection(value, 'location');
  String? validateBranch(String? value) => validateSelection(value, 'branch');

  // Dropdown update methods
  void updateLocation(String? value) {
    debugPrint('RegistrationProvider: Updating location to: $value');
    selectedLocation = value;
    notifyListeners();
  }

  void updateBranch(String? value) {
    debugPrint('RegistrationProvider: Updating branch to: $value');
    selectedBranch = value;
    notifyListeners();
  }

  void updatePaymentOption(String value) {
    selectedPaymentOption = value;
    notifyListeners();
  }

  void updateHour(String? value) {
    selectedHour = value ?? '12';
    notifyListeners();
  }

  void updateMinute(String? value) {
    selectedMinute = value ?? '00';
    notifyListeners();
  }

  // Data fetching methods

  // Treatment methods
  void updateSelectedTreatments(List<Treatment> treatments) {
    debugPrint(
      'RegistrationProvider: Updating selected treatments with ${treatments.length} treatments',
    );
    selectedTreatments = treatments;
    notifyListeners();
  }

  void removeTreatment(int index) {
    debugPrint('RegistrationProvider: Removing treatment at index $index');
    selectedTreatments.removeAt(index);
    notifyListeners();
  }

  // Treatment selection bottom sheet methods
  void initializeTreatmentSelection() {
    debugPrint('RegistrationProvider: Initializing treatment selection');
    treatments = List.from(selectedTreatments);
    selectedTreatment = null;
    maleCount = 0;
    femaleCount = 0;
    notifyListeners();
  }

  void updateSelectedTreatment(
    String? value,
    TreatmentTypeProvider treatmentProvider,
  ) {
    debugPrint('RegistrationProvider: Updating selected treatment to: $value');
    // Ensure the selected treatment is valid and exists in available treatments
    if (value != null && treatmentProvider.isValidActiveTreatment(value)) {
      selectedTreatment = value;
    } else if (value == null) {
      selectedTreatment = null;
    } else {
      debugPrint(
        'RegistrationProvider: Warning - Invalid treatment selected: $value',
      );
      selectedTreatment = null;
    }
    notifyListeners();
  }

  void incrementCount(bool isMale) {
    debugPrint(
      'RegistrationProvider: Incrementing ${isMale ? 'male' : 'female'} count',
    );
    if (isMale) {
      maleCount++;
    } else {
      femaleCount++;
    }
    notifyListeners();
  }

  void decrementCount(bool isMale) {
    debugPrint(
      'RegistrationProvider: Decrementing ${isMale ? 'male' : 'female'} count',
    );
    if (isMale && maleCount > 0) {
      maleCount--;
    } else if (!isMale && femaleCount > 0) {
      femaleCount--;
    }
    notifyListeners();
  }

  void saveTreatment() {
    debugPrint(
      'RegistrationProvider: Saving treatment - $selectedTreatment, Male: $maleCount, Female: $femaleCount',
    );
    if (selectedTreatment != null && (maleCount > 0 || femaleCount > 0)) {
      final treatment = Treatment(
        name: selectedTreatment!,
        maleCount: maleCount,
        femaleCount: femaleCount,
      );

      // Check if treatment already exists
      final existingIndex = treatments.indexWhere(
        (t) => t.name == selectedTreatment,
      );
      if (existingIndex != -1) {
        debugPrint(
          'RegistrationProvider: Updating existing treatment at index $existingIndex',
        );
        treatments[existingIndex] = treatment;
      } else {
        debugPrint('RegistrationProvider: Adding new treatment');
        treatments.add(treatment);
      }

      updateSelectedTreatments(treatments);

      // Reset selection state
      selectedTreatment = null;
      maleCount = 0;
      femaleCount = 0;
      notifyListeners();
    } else {
      debugPrint(
        'RegistrationProvider: Cannot save treatment - missing required data',
      );
    }
  }

  // Registration method
  Future<bool> registerPatient({
    required BuildContext context,
    required TreatmentTypeProvider treatmentProvider,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      Uri url = Uri.parse(ApiUrls.registerPatient());
      debugPrint('Register Patient API URL: $url');

      // Prepare form data
      Map<String, String> formData = {
        'name': nameController.text,
        'excecutive': 'Executive Name', // Empty as per requirements
        'payment': selectedPaymentOption,
        'phone': whatsappController.text,
        'address': addressController.text,
        'total_amount':
            totalAmountController.text.isEmpty
                ? '0'
                : totalAmountController.text,
        'discount_amount':
            discountAmountController.text.isEmpty
                ? '0'
                : discountAmountController.text,
        'advance_amount':
            advanceAmountController.text.isEmpty
                ? '0'
                : advanceAmountController.text,
        'balance_amount':
            balanceAmountController.text.isEmpty
                ? '0'
                : balanceAmountController.text,
        'date_nd_time':
            '${treatmentDateController.text}-$selectedHour:$selectedMinute $selectedPeriod',
        'id': '', // Empty string as per requirements
        'male': _getMaleTreatmentIds(treatmentProvider),
        'female': _getFemaleTreatmentIds(treatmentProvider),
        'branch': '',
        'treatments': _getAllTreatmentIds(treatmentProvider),
      };

      debugPrint('=== Register Patient Data ===');
      debugPrint('Form Data: $formData');

      // Get auth token
      String authToken = await SharedUtils.getString(StringClass.token);

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $authToken',
        },
        body: formData,
      );

      var data = jsonDecode(response.body);
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        if (data['status'] == true) {
          if (context.mounted) {
            AppUtils.showToast(
              context,
              'Success',
              'Successfully registered patient',
              true,
            );

            // Generate and show PDF receipt
            await _generateReceipt(context, treatmentProvider);

            // Reset form after successful registration
            resetForm();
          }
          return true;
        } else {
          if (context.mounted) {
            AppUtils.showToast(
              context,
              'Error',
              'Failed to register patient',
              false,
            );
          }
          return false;
        }
      } else if (response.statusCode == 409) {
        if (context.mounted) {
          AppUtils.showToast(
            context,
            'Error',
            'Failed to register patient',
            false,
          );
        }
        return false;
      } else {
        if (context.mounted) {
          AppUtils.showToast(
            context,
            'Error',
            'Failed to register patient',
            false,
          );
        }
        return false;
      }
    } catch (error) {
      if (context.mounted) {
        AppUtils.showToast(
          context,
          'Error',
          'Failed to register patient',
          false,
        );
      }
      debugPrint('Error in registerPatient: $error');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get male treatment ID (single value only)
  String _getMaleTreatmentIds(TreatmentTypeProvider treatmentProvider) {
    debugPrint('RegistrationProvider: Getting male treatment ID');
    
    for (var treatment in selectedTreatments) {
      if (treatment.maleCount > 0) {
        // Find the treatment ID from the API data
        String? treatmentId = treatmentProvider.getTreatmentIdByName(
          treatment.name,
        );
        if (treatmentId != null) {
          debugPrint(
            'RegistrationProvider: Found male treatment ID $treatmentId for name "${treatment.name}"',
          );
          return treatmentId; // Return first treatment ID found
        } else {
          debugPrint(
            'RegistrationProvider: Warning - No treatment ID found for name "${treatment.name}"',
          );
        }
      }
    }
    
    debugPrint('RegistrationProvider: No male treatment ID found');
    return ''; // Return empty string if no male treatment found
  }

  // Helper method to get female treatment ID (single value only)
  String _getFemaleTreatmentIds(TreatmentTypeProvider treatmentProvider) {
    debugPrint('RegistrationProvider: Getting female treatment ID');
    
    for (var treatment in selectedTreatments) {
      if (treatment.femaleCount > 0) {
        // Find the treatment ID from the API data
        String? treatmentId = treatmentProvider.getTreatmentIdByName(
          treatment.name,
        );
        if (treatmentId != null) {
          debugPrint(
            'RegistrationProvider: Found female treatment ID $treatmentId for name "${treatment.name}"',
          );
          return treatmentId; // Return first treatment ID found
        } else {
          debugPrint(
            'RegistrationProvider: Warning - No treatment ID found for name "${treatment.name}"',
          );
        }
      }
    }
    
    debugPrint('RegistrationProvider: No female treatment ID found');
    return ''; // Return empty string if no female treatment found
  }

  // Helper method to get all treatment IDs (comma-separated for treatments field)
  String _getAllTreatmentIds(TreatmentTypeProvider treatmentProvider) {
    debugPrint('RegistrationProvider: Getting all treatment IDs');
    List<String> allIds = [];
    
    for (var treatment in selectedTreatments) {
      if (treatment.maleCount > 0 || treatment.femaleCount > 0) {
        // Find the treatment ID from the API data
        String? treatmentId = treatmentProvider.getTreatmentIdByName(
          treatment.name,
        );
        if (treatmentId != null) {
          allIds.add(treatmentId);
          debugPrint(
            'RegistrationProvider: Found treatment ID $treatmentId for name "${treatment.name}"',
          );
        } else {
          debugPrint(
            'RegistrationProvider: Warning - No treatment ID found for name "${treatment.name}"',
          );
        }
      }
    }
    
    String result = allIds.join(',');
    debugPrint('RegistrationProvider: All treatment IDs: $result');
    return result;
  }

  // Method to generate PDF receipt
  Future<void> _generateReceipt(
    BuildContext context,
    TreatmentTypeProvider treatmentProvider,
  ) async {
    try {
      debugPrint('RegistrationProvider: Generating PDF receipt');

      await PdfGeneratorService.generateAndShowReceipt(
        context: context,
        patientName: nameController.text,
        address: addressController.text,
        whatsappNumber: whatsappController.text,
        treatmentDate: treatmentDateController.text,
        treatmentTime: '$selectedHour:$selectedMinute $selectedPeriod',
        selectedTreatments: selectedTreatments,
        treatmentProvider: treatmentProvider,
        totalAmount:
            totalAmountController.text.isEmpty
                ? '0'
                : totalAmountController.text,
        discountAmount:
            discountAmountController.text.isEmpty
                ? '0'
                : discountAmountController.text,
        advanceAmount:
            advanceAmountController.text.isEmpty
                ? '0'
                : advanceAmountController.text,
        balanceAmount:
            balanceAmountController.text.isEmpty
                ? '0'
                : balanceAmountController.text,
        selectedLocation: selectedLocation ?? '',
        selectedBranch: selectedBranch ?? '',
      );

      debugPrint('RegistrationProvider: PDF receipt generated successfully');
    } catch (e) {
      debugPrint('RegistrationProvider: Error generating PDF receipt - $e');
      if (context.mounted) {
        AppUtils.showToast(
          context,
          'Error',
          'Failed to generate PDF receipt',
          false,
        );
      }
    }
  }

  // Reset form method
  void resetForm() {
    nameController.clear();
    whatsappController.clear();
    addressController.clear();
    totalAmountController.clear();
    discountAmountController.clear();
    advanceAmountController.clear();
    balanceAmountController.clear();
    treatmentDateController.clear();

    selectedLocation = null;
    selectedBranch = null;
    selectedPaymentOption = 'Cash';
    selectedHour = '12';
    selectedMinute = '00';
    selectedPeriod = 'AM';
    selectedDateTime = null;
    selectedTreatments.clear();

    notifyListeners();
  }
}
