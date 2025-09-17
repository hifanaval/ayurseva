import 'package:flutter/material.dart';
import 'package:ayurseva/screens/registration_screen/registration_screen.dart';
import 'package:ayurseva/screens/registration_screen/provider/branch_provider.dart';
import 'package:ayurseva/screens/registration_screen/provider/treatment_type_provider.dart';
import 'package:ayurseva/constants/api_urls.dart';
import 'package:ayurseva/constants/string_class.dart';
import 'package:ayurseva/utils/shared_utils.dart';
import 'package:ayurseva/utils/app_utils.dart';
import 'package:ayurseva/utils/pdf_generator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
  final TextEditingController discountAmountController = TextEditingController();
  final TextEditingController advanceAmountController = TextEditingController();
  final TextEditingController balanceAmountController = TextEditingController();
  final TextEditingController treatmentDateController = TextEditingController();

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

  // Available treatments list (will be populated from TreatmentTypeProvider)
  List<String> availableTreatments = [];

  // Static locations
  final List<String> locations = [
    'Kochi,kerala',
    'Kozhikode', 
    'Kumarakom'
  ];
  
  // Branches from API
  List<String> branches = [];
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
    
    print('RegistrationProvider: Updated time - $selectedHour:$selectedMinute $selectedPeriod');
    notifyListeners();
  }
  
  void updateTimeFromWheels() {
    final hour = selectedHourIndex + 1;
    final minute = selectedMinuteIndex;
    final time = TimeOfDay(
      hour: selectedPeriod == 'AM' 
          ? (hour == 12 ? 0 : hour)
          : (hour == 12 ? 12 : hour + 12),
      minute: minute,
    );
    selectedTime = time;
    notifyListeners();
  }
  
 DateTime? selectedTreatmentDate;
  DateTime? tempSelectedDate;
  DateTime? focusedDay;
  DateTimeRange? selectedDateRange;
  
  final TextEditingController dateRangeController = TextEditingController();
  
  void updateTreatmentDate(DateTime date) {
    selectedTreatmentDate = date;
    treatmentDateController.text = DateFormat('dd/MM/yyyy').format(date);
    notifyListeners();
  }
  
  void updateCalendarSelection(DateTime selectedDay, DateTime focusedDay) {
    selectedTreatmentDate = selectedDay;
    this.focusedDay = focusedDay;
    notifyListeners();
  }
  
  void confirmDateSelection() {
    if (selectedTreatmentDate != null) {
      treatmentDateController.text = DateFormat('dd/MM/yyyy').format(selectedTreatmentDate!);
    }
    notifyListeners();
  }
  
  void updateDateRange(DateTimeRange range) {
    selectedDateRange = range;
    dateRangeController.text = 
        '${DateFormat('dd/MM/yyyy').format(range.start)} - ${DateFormat('dd/MM/yyyy').format(range.end)}';
    notifyListeners();
  }
  
 
  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateWhatsApp(String? value) {
    if (value == null || value.isEmpty) {
      return 'WhatsApp number is required';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  String? validateLocation(String? value) {
    if (value == null) return 'Please select a location';
    return null;
  }

  String? validateBranch(String? value) {
    if (value == null) return 'Please select a branch';
    return null;
  }

  // Dropdown update methods
  void updateLocation(String? value) {
    print('RegistrationProvider: Updating location to: $value');
    selectedLocation = value;
    notifyListeners();
  }

  void updateBranch(String? value) {
    print('RegistrationProvider: Updating branch to: $value');
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
  Future<void> fetchBranchData(BuildContext context, BranchProvider branchProvider) async {
    print('RegistrationProvider: Fetching branch data');
    try {
      await branchProvider.fetchBranchData(context);
      
      if (branchProvider.branches != null) {
        // Extract branch names from API data
        List<String> branchNames = [];
        
        for (var branch in branchProvider.branches!) {
          if (branch.name != null) {
            branchNames.add(branch.name!);
          }
        }
        
        branches = branchNames;
        
        print('RegistrationProvider: Branch data processed - ${branches.length} branches from API');
        print('RegistrationProvider: Using static locations: ${locations.join(", ")}');
        notifyListeners();
      }
    } catch (e) {
      print('RegistrationProvider: Error fetching branch data - $e');
    }
  }

  Future<void> fetchTreatmentData(BuildContext context, TreatmentTypeProvider treatmentProvider) async {
    print('RegistrationProvider: Fetching treatment data');
    try {
      await treatmentProvider.fetchTreatmentData(context);
      
      if (treatmentProvider.treatments.isNotEmpty) {
        // Get unique treatment names to avoid duplicate dropdown values
        final treatmentNames = treatmentProvider.treatments
            .where((treatment) => treatment.isActive == true && treatment.name != null)
            .map((treatment) => treatment.name!)
            .toSet() // Use Set to remove duplicates
            .toList();
        
        availableTreatments = treatmentNames;
        
        // Clear selected treatment if it's no longer available
        if (selectedTreatment != null && !availableTreatments.contains(selectedTreatment)) {
          selectedTreatment = null;
          print('RegistrationProvider: Cleared invalid selected treatment');
        }
        
        print('RegistrationProvider: Treatment data processed - ${availableTreatments.length} unique active treatments');
        notifyListeners();
      }
    } catch (e) {
      print('RegistrationProvider: Error fetching treatment data - $e');
    }
  }

  // Method to get all branches from API (no filtering)
  List<String> getAllBranches(BranchProvider branchProvider) {
    if (branchProvider.branches == null) {
      return branches;
    }
    
    List<String> allBranches = [];
    for (var branch in branchProvider.branches!) {
      if (branch.name != null) {
        allBranches.add(branch.name!);
      }
    }
    
    print('RegistrationProvider: Showing all branches from API: ${allBranches.length} branches');
    return allBranches;
  }

  // Treatment methods
  void updateSelectedTreatments(List<Treatment> treatments) {
    print('RegistrationProvider: Updating selected treatments with ${treatments.length} treatments');
    selectedTreatments = treatments;
    notifyListeners();
  }

  void removeTreatment(int index) {
    print('RegistrationProvider: Removing treatment at index $index');
    selectedTreatments.removeAt(index);
    notifyListeners();
  }

  // Treatment selection bottom sheet methods
  void initializeTreatmentSelection() {
    print('RegistrationProvider: Initializing treatment selection');
    treatments = List.from(selectedTreatments);
    selectedTreatment = null;
    maleCount = 0;
    femaleCount = 0;
    notifyListeners();
  }

  void updateSelectedTreatment(String? value) {
    print('RegistrationProvider: Updating selected treatment to: $value');
    // Ensure the selected treatment is valid and exists in available treatments
    if (value != null && availableTreatments.contains(value)) {
      selectedTreatment = value;
    } else if (value == null) {
      selectedTreatment = null;
    } else {
      print('RegistrationProvider: Warning - Invalid treatment selected: $value');
      selectedTreatment = null;
    }
    notifyListeners();
  }

  void incrementCount(bool isMale) {
    print('RegistrationProvider: Incrementing ${isMale ? 'male' : 'female'} count');
    if (isMale) {
      maleCount++;
    } else {
      femaleCount++;
    }
    notifyListeners();
  }

  void decrementCount(bool isMale) {
    print('RegistrationProvider: Decrementing ${isMale ? 'male' : 'female'} count');
    if (isMale && maleCount > 0) {
      maleCount--;
    } else if (!isMale && femaleCount > 0) {
      femaleCount--;
    }
    notifyListeners();
  }

  void saveTreatment() {
    print('RegistrationProvider: Saving treatment - $selectedTreatment, Male: $maleCount, Female: $femaleCount');
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
        print('RegistrationProvider: Updating existing treatment at index $existingIndex');
        treatments[existingIndex] = treatment;
      } else {
        print('RegistrationProvider: Adding new treatment');
        treatments.add(treatment);
      }

      updateSelectedTreatments(treatments);
      
      // Reset selection state
      selectedTreatment = null;
      maleCount = 0;
      femaleCount = 0;
      notifyListeners();
    } else {
      print('RegistrationProvider: Cannot save treatment - missing required data');
    }
  }

  // Date selection method
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      treatmentDateController.text =
          "${picked.day}/${picked.month}/${picked.year}";
      notifyListeners();
    }
  }

  // Form submission method
  Future<void> submitForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      // TODO: Implement form submission logic
      print('Form submitted successfully');
      print('Name: ${nameController.text}');
      print('WhatsApp: ${whatsappController.text}');
      print('Address: ${addressController.text}');
      print('Location: $selectedLocation');
      print('Branch: $selectedBranch');
      print('Payment Option: $selectedPaymentOption');
      print('Treatment Date: ${treatmentDateController.text}');
      print('Treatment Time: $selectedHour:$selectedMinute');
      print('Selected Treatments: ${selectedTreatments.length}');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted successfully!'),
          backgroundColor: Colors.green,
        ),
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
        'excecutive': '', // Empty as per requirements
        'payment': selectedPaymentOption,
        'phone': whatsappController.text,
        'address': addressController.text,
        'total_amount': totalAmountController.text.isEmpty ? '0' : totalAmountController.text,
        'discount_amount': discountAmountController.text.isEmpty ? '0' : discountAmountController.text,
        'advance_amount': advanceAmountController.text.isEmpty ? '0' : advanceAmountController.text,
        'balance_amount': balanceAmountController.text.isEmpty ? '0' : balanceAmountController.text,
        'date_nd_time': '${treatmentDateController.text}-$selectedHour:$selectedMinute $selectedPeriod',
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
                context, 'Success', 'Successfully registered patient', true);
            
            // Generate and show PDF receipt
            await _generateReceipt(context, treatmentProvider);
            
            // Reset form after successful registration
            resetForm();
          }
          return true;
        } else {
          if (context.mounted) {
            AppUtils.showToast(context, 'Error', 'Failed to register patient', false);
          }
          return false;
        }
      } else if (response.statusCode == 409) {
        if (context.mounted) {
          AppUtils.showToast(context, 'Error', 'Failed to register patient', false);
        }
        return false;
      } else {
        if (context.mounted) {
          AppUtils.showToast(context, 'Error', 'Failed to register patient', false);
        }
        return false;
      }
    } catch (error) {
      if (context.mounted) {
        AppUtils.showToast(context, 'Error', 'Failed to register patient', false);
      }
      debugPrint('Error in registerPatient: $error');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get male treatment IDs
  String _getMaleTreatmentIds(TreatmentTypeProvider treatmentProvider) {
    List<String> maleIds = [];
    for (var treatment in selectedTreatments) {
      if (treatment.maleCount > 0) {
        // Find the treatment ID from the API data
        String? treatmentId = _getTreatmentIdByName(treatment.name, treatmentProvider);
        if (treatmentId != null) {
          maleIds.add(treatmentId);
        }
      }
    }
    print('RegistrationProvider: Male treatment IDs: ${maleIds.join(',')}');
    return maleIds.join(',');
  }

  // Helper method to get female treatment IDs
  String _getFemaleTreatmentIds(TreatmentTypeProvider treatmentProvider) {
    List<String> femaleIds = [];
    for (var treatment in selectedTreatments) {
      if (treatment.femaleCount > 0) {
        // Find the treatment ID from the API data
        String? treatmentId = _getTreatmentIdByName(treatment.name, treatmentProvider);
        if (treatmentId != null) {
          femaleIds.add(treatmentId);
        }
      }
    }
    print('RegistrationProvider: Female treatment IDs: ${femaleIds.join(',')}');
    return femaleIds.join(',');
  }

  // Helper method to get all treatment IDs
  String _getAllTreatmentIds(TreatmentTypeProvider treatmentProvider) {
    List<String> allIds = [];
    for (var treatment in selectedTreatments) {
      if (treatment.maleCount > 0 || treatment.femaleCount > 0) {
        // Find the treatment ID from the API data
        String? treatmentId = _getTreatmentIdByName(treatment.name, treatmentProvider);
        if (treatmentId != null) {
          allIds.add(treatmentId);
        }
      }
    }
    print('RegistrationProvider: All treatment IDs: ${allIds.join(',')}');
    return allIds.join(',');
  }

  // Helper method to get treatment ID by name from API data
  String? _getTreatmentIdByName(String treatmentName, TreatmentTypeProvider treatmentProvider) {
    // Find the treatment in the API data by name
    for (var apiTreatment in treatmentProvider.treatments) {
      if (apiTreatment.name == treatmentName && apiTreatment.id != null) {
        print('RegistrationProvider: Found treatment ID ${apiTreatment.id} for name "$treatmentName"');
        return apiTreatment.id.toString();
      }
    }
    print('RegistrationProvider: Warning - No treatment ID found for name "$treatmentName"');
    return null;
  }

  // Method to generate PDF receipt
  Future<void> _generateReceipt(BuildContext context, TreatmentTypeProvider treatmentProvider) async {
    try {
      print('RegistrationProvider: Generating PDF receipt');
      
      await InvoiceGenerator.generateAndShowReceipt(
        context: context,
        patientName: nameController.text,
        address: addressController.text,
        whatsappNumber: whatsappController.text,
        treatmentDate: treatmentDateController.text,
        treatmentTime: '$selectedHour:$selectedMinute $selectedPeriod',
        selectedTreatments: selectedTreatments,
        treatmentProvider: treatmentProvider,
        totalAmount: totalAmountController.text.isEmpty ? '0' : totalAmountController.text,
        discountAmount: discountAmountController.text.isEmpty ? '0' : discountAmountController.text,
        advanceAmount: advanceAmountController.text.isEmpty ? '0' : advanceAmountController.text,
        balanceAmount: balanceAmountController.text.isEmpty ? '0' : balanceAmountController.text,
        selectedLocation: selectedLocation ?? '',
        selectedBranch: selectedBranch ?? '',
      );
      
      print('RegistrationProvider: PDF receipt generated successfully');
    } catch (e) {
      print('RegistrationProvider: Error generating PDF receipt - $e');
      if (context.mounted) {
        AppUtils.showToast(context, 'Error', 'Failed to generate PDF receipt', false);
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

  // Dispose method
  @override
  void dispose() {
    nameController.dispose();
    whatsappController.dispose();
    addressController.dispose();
    totalAmountController.dispose();
    discountAmountController.dispose();
    advanceAmountController.dispose();
    balanceAmountController.dispose();
    treatmentDateController.dispose();
    super.dispose();
  }
}
