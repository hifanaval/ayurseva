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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(debugLabel: 'RegistrationFormKey');
  
  // Validation error states
  String? nameError;
  String? whatsappError;
  String? addressError;
  String? locationError;
  String? branchError;
  String? totalAmountError;
  String? discountAmountError;
  String? advanceAmountError;
  String? balanceAmountError;
  String? treatmentDateError;
  String? treatmentTimeError;
  String? treatmentsError;
  String? amountConsistencyError;

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

  

  // Clear specific error method
  void clearError(String errorType) {
    debugPrint('RegistrationProvider: Clearing error for $errorType');
    switch (errorType) {
      case 'name':
        nameError = null;
        break;
      case 'whatsapp':
        whatsappError = null;
        break;
      case 'address':
        addressError = null;
        break;
      case 'location':
        locationError = null;
        break;
      case 'branch':
        branchError = null;
        break;
      case 'totalAmount':
        totalAmountError = null;
        break;
      case 'discountAmount':
        discountAmountError = null;
        break;
      case 'advanceAmount':
        advanceAmountError = null;
        break;
      case 'balanceAmount':
        balanceAmountError = null;
        break;
      case 'treatmentDate':
        treatmentDateError = null;
        break;
      case 'treatmentTime':
        treatmentTimeError = null;
        break;
      case 'treatments':
        treatmentsError = null;
        break;
      case 'amountConsistency':
        amountConsistencyError = null;
        break;
      default:
        debugPrint('RegistrationProvider: Unknown error type: $errorType');
        return;
    }
    notifyListeners();
  }

  // Clear all errors
  void clearAllErrors() {
nameError = null;
whatsappError = null;
addressError = null;
locationError = null;
branchError = null;
totalAmountError = null;
discountAmountError = null;
advanceAmountError = null;
balanceAmountError = null;
treatmentDateError = null;
treatmentTimeError = null;
treatmentsError = null;
amountConsistencyError = null;
    notifyListeners();
  }

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

  // Enhanced validation methods
  String? validateName(String? value) {
    debugPrint('RegistrationProvider: Validating name - $value');
    if (value == null || value.isEmpty) {
      nameError = 'Name is required';
      notifyListeners();
      return nameError;
    }
    if (value.length < 2) {
      nameError = 'Name must be at least 2 characters';
      notifyListeners();
      return nameError;
    }
    if (value.length > 50) {
      nameError = 'Name must be less than 50 characters';
      notifyListeners();
      return nameError;
    }
    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      nameError = 'Name can only contain letters, spaces, hyphens, and apostrophes';
      notifyListeners();
      return nameError;
    }
    nameError = null;
    notifyListeners();
    return null;
  }

  String? validateWhatsApp(String? value) {
    debugPrint('RegistrationProvider: Validating WhatsApp - $value');
    if (value == null || value.isEmpty) {
      whatsappError = 'WhatsApp number is required';
      notifyListeners();
      return whatsappError;
    }
    
    // Remove any non-digit characters for validation
    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.length < 10) {
      whatsappError = 'WhatsApp number must be at least 10 digits';
      notifyListeners();
      return whatsappError;
    }
    if (cleanNumber.length > 15) {
      whatsappError = 'WhatsApp number must be less than 15 digits';
      notifyListeners();
      return whatsappError;
    }
    
    // Check if it starts with valid country codes (optional)
    if (!cleanNumber.startsWith(RegExp(r'^[1-9]'))) {
      whatsappError = 'WhatsApp number must start with a valid digit';
      notifyListeners();
      return whatsappError;
    }
    
    whatsappError = null;
    notifyListeners();
    return null;
  }

  String? validateAddress(String? value) {
    debugPrint('RegistrationProvider: Validating address - $value');
    if (value == null || value.isEmpty) {
      addressError = 'Address is required';
      notifyListeners();
      return addressError;
    }
    if (value.length < 10) {
      addressError = 'Address must be at least 10 characters';
      notifyListeners();
      return addressError;
    }
    if (value.length > 200) {
      addressError = 'Address must be less than 200 characters';
      notifyListeners();
      return addressError;
    }
    addressError = null;
    notifyListeners();
    return null;
  }

  String? validateLocation(String? value) {
    debugPrint('RegistrationProvider: Validating location - $value');
    if (value == null) {
      locationError = 'Please select a location';
      notifyListeners();
      return locationError;
    }
    locationError = null;
    notifyListeners();
    return null;
  }

  String? validateBranch(String? value) {
    debugPrint('RegistrationProvider: Validating branch - $value');
    if (value == null) {
      branchError = 'Please select a branch';
      notifyListeners();
      return branchError;
    }
    branchError = null;
    notifyListeners();
    return null;
  }

  String? validateTotalAmount(String? value) {
    debugPrint('RegistrationProvider: Validating total amount - $value');
    if (value == null || value.isEmpty) {
      totalAmountError = 'Total amount is required';
      notifyListeners();
      return totalAmountError;
    }
    
    // Remove any non-digit characters except decimal point
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    if (cleanValue.isEmpty) {
      totalAmountError = 'Total amount must be a valid number';
      notifyListeners();
      return totalAmountError;
    }
    
    final amount = double.tryParse(cleanValue);
    if (amount == null) {
      totalAmountError = 'Total amount must be a valid number';
      notifyListeners();
      return totalAmountError;
    }
    
    if (amount < 0) {
      totalAmountError = 'Total amount cannot be negative';
      notifyListeners();
      return totalAmountError;
    }
    
    if (amount > 999999) {
      totalAmountError = 'Total amount must be less than 1,000,000';
      notifyListeners();
      return totalAmountError;
    }
    
    totalAmountError = null;
    notifyListeners();
    return null;
  }

  String? validateDiscountAmount(String? value) {
    debugPrint('RegistrationProvider: Validating discount amount - $value');
    if (value == null || value.isEmpty) {
      discountAmountError = 'Discount amount is required';
      notifyListeners();
      return discountAmountError;
    }
    
    // Remove any non-digit characters except decimal point
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    if (cleanValue.isEmpty) {
      discountAmountError = 'Discount amount must be a valid number';
      notifyListeners();
      return discountAmountError;
    }
    
    final amount = double.tryParse(cleanValue);
    if (amount == null) {
      discountAmountError = 'Discount amount must be a valid number';
      notifyListeners();
      return discountAmountError;
    }
    
    if (amount < 0) {
      discountAmountError = 'Discount amount cannot be negative';
      notifyListeners();
      return discountAmountError;
    }
    
    if (amount > 999999) {
      discountAmountError = 'Discount amount must be less than 1,000,000';
      notifyListeners();
      return discountAmountError;
    }
    
    discountAmountError = null;
    notifyListeners();
    return null;
  }

  String? validateAdvanceAmount(String? value) {
    debugPrint('RegistrationProvider: Validating advance amount - $value');
    if (value == null || value.isEmpty) {
      advanceAmountError = 'Advance amount is required';
      notifyListeners();
      return advanceAmountError;
    }
    
    // Remove any non-digit characters except decimal point
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    if (cleanValue.isEmpty) {
      advanceAmountError = 'Advance amount must be a valid number';
      notifyListeners();
      return advanceAmountError;
    }
    
    final amount = double.tryParse(cleanValue);
    if (amount == null) {
      advanceAmountError = 'Advance amount must be a valid number';
      notifyListeners();
      return advanceAmountError;
    }
    
    if (amount < 0) {
      advanceAmountError = 'Advance amount cannot be negative';
      notifyListeners();
      return advanceAmountError;
    }
    
    if (amount > 999999) {
      advanceAmountError = 'Advance amount must be less than 1,000,000';
      notifyListeners();
      return advanceAmountError;
    }
    
    advanceAmountError = null;
    notifyListeners();
    return null;
  }

  String? validateBalanceAmount(String? value) {
    debugPrint('RegistrationProvider: Validating balance amount - $value');
    if (value == null || value.isEmpty) {
      balanceAmountError = 'Balance amount is required';
      notifyListeners();
      return balanceAmountError;
    }
    
    // Remove any non-digit characters except decimal point
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    if (cleanValue.isEmpty) {
      balanceAmountError = 'Balance amount must be a valid number';
      notifyListeners();
      return balanceAmountError;
    }
    
    final amount = double.tryParse(cleanValue);
    if (amount == null) {
      balanceAmountError = 'Balance amount must be a valid number';
      notifyListeners();
      return balanceAmountError;
    }
    
    if (amount < 0) {
      balanceAmountError = 'Balance amount cannot be negative';
      notifyListeners();
      return balanceAmountError;
    }
    
    if (amount > 999999) {
      balanceAmountError = 'Balance amount must be less than 1,000,000';
      notifyListeners();
      return balanceAmountError;
    }
    
    balanceAmountError = null;
    notifyListeners();
    return null;
  }

  String? validateTreatmentDate(String? value) {
    debugPrint('RegistrationProvider: Validating treatment date - $value');
    if (value == null || value.isEmpty) {
      treatmentDateError = 'Treatment date is required';
      notifyListeners();
      return treatmentDateError;
    }
    
    if (selectedTreatmentDate == null) {
      treatmentDateError = 'Please select a valid treatment date';
      notifyListeners();
      return treatmentDateError;
    }
    
    // Check if date is not in the past
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(selectedTreatmentDate!.year, selectedTreatmentDate!.month, selectedTreatmentDate!.day);
    
    if (selectedDate.isBefore(today)) {
      treatmentDateError = 'Treatment date cannot be in the past';
      notifyListeners();
      return treatmentDateError;
    }
    
    treatmentDateError = null;
    notifyListeners();
    return null;
  }

  String? validateTreatmentTime() {
    debugPrint('RegistrationProvider: Validating treatment time');
    if (selectedDateTime == null) {
      treatmentTimeError = 'Treatment time is required';
      notifyListeners();
      return treatmentTimeError;
    }
    treatmentTimeError = null;
    notifyListeners();
    return null;
  }

  String? validateTreatments() {
    debugPrint('RegistrationProvider: Validating treatments - ${selectedTreatments.length} selected');
    if (selectedTreatments.isEmpty) {
      treatmentsError = 'At least one treatment must be selected';
      notifyListeners();
      return treatmentsError;
    }
    
    // Check if any treatment has valid counts
    bool hasValidTreatment = false;
    for (var treatment in selectedTreatments) {
      if (treatment.maleCount > 0 || treatment.femaleCount > 0) {
        hasValidTreatment = true;
        break;
      }
    }
    
    if (!hasValidTreatment) {
      treatmentsError = 'At least one treatment must have male or female count greater than 0';
      notifyListeners();
      return treatmentsError;
    }
    
    treatmentsError = null;
    notifyListeners();
    return null;
  }

  String? validateAmountConsistency() {
    debugPrint('RegistrationProvider: Validating amount consistency');
    
    final total = double.tryParse(totalAmountController.text) ?? 0.0;
    final discount = double.tryParse(discountAmountController.text) ?? 0.0;
    final advance = double.tryParse(advanceAmountController.text) ?? 0.0;
    final balance = double.tryParse(balanceAmountController.text) ?? 0.0;
    
    // Check if advance + balance equals total - discount
    final expectedBalance = total - discount - advance;
    final tolerance = 0.01; // Allow small floating point differences
    
    if ((balance - expectedBalance).abs() > tolerance) {
      amountConsistencyError = 'Balance amount should equal Total - Discount - Advance';
      notifyListeners();
      return amountConsistencyError;
    }
    
    if (advance > total - discount) {
      amountConsistencyError = 'Advance amount cannot be greater than Total - Discount';
      notifyListeners();
      return amountConsistencyError;
    }
    
    amountConsistencyError = null;
    notifyListeners();
    return null;
  }

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

  // Auto-calculate balance amount
  void calculateBalanceAmount() {
    debugPrint('RegistrationProvider: Calculating balance amount');
    
    final total = double.tryParse(totalAmountController.text) ?? 0.0;
    final discount = double.tryParse(discountAmountController.text) ?? 0.0;
    final advance = double.tryParse(advanceAmountController.text) ?? 0.0;
    
    final balance = total - discount - advance;
    
    if (balance >= 0) {
      balanceAmountController.text = balance.toStringAsFixed(0);
      debugPrint('RegistrationProvider: Balance calculated as $balance');
    } else {
      balanceAmountController.text = '0';
      debugPrint('RegistrationProvider: Balance set to 0 (negative value)');
    }
    
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

  // Comprehensive form validation
  bool validateForm(BuildContext context) {
    debugPrint('RegistrationProvider: Starting comprehensive form validation');
    
    // Validate all form fields
    validateName(nameController.text);
    validateWhatsApp(whatsappController.text);
    validateAddress(addressController.text);
    validateLocation(selectedLocation);
    validateBranch(selectedBranch);
    validateTotalAmount(totalAmountController.text);
    validateDiscountAmount(discountAmountController.text);
    validateAdvanceAmount(advanceAmountController.text);
    validateBalanceAmount(balanceAmountController.text);
    validateTreatmentDate(treatmentDateController.text);
    validateTreatmentTime();
    validateTreatments();
    validateAmountConsistency();
    
    // Check if any validation failed
    final hasErrors = nameError != null ||
        whatsappError != null ||
        addressError != null ||
        locationError != null ||
        branchError != null ||
        totalAmountError != null ||
        discountAmountError != null ||
        advanceAmountError != null ||
        balanceAmountError != null ||
        treatmentDateError != null ||
        treatmentTimeError != null ||
        treatmentsError != null ||
        amountConsistencyError != null;
    
    if (hasErrors) {
      debugPrint('RegistrationProvider: Form validation failed');
      return false;
    }
    
    debugPrint('RegistrationProvider: Form validation passed');
    return true;
  }

  // Registration method
  Future<bool> registerPatient({
    required BuildContext context,
    required TreatmentTypeProvider treatmentProvider,
  }) async {
    try {
      // Validate form before proceeding
      if (!validateForm(context)) {
        debugPrint('RegistrationProvider: Form validation failed, aborting registration');
        return false;
      }
      
      debugPrint('RegistrationProvider: Form validation passed, proceeding with registration');
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
