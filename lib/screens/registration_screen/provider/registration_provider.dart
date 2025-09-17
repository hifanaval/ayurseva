import 'package:flutter/material.dart';
import 'package:ayurseva/screens/registration_screen/registration_screen.dart';
import 'package:ayurseva/screens/registration_screen/provider/branch_provider.dart';
import 'package:ayurseva/screens/registration_screen/provider/treatment_type_provider.dart';
import 'package:intl/intl.dart';

class RegistrationProvider extends ChangeNotifier {
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
  String selectedHour = 'Hour';
  String selectedMinute = 'Minutes';
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

  // Data from providers
  List<String> locations = [];
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
    // Reset branch selection when location changes
    selectedBranch = null;
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
    selectedHour = value ?? 'Hour';
    notifyListeners();
  }

  void updateMinute(String? value) {
    selectedMinute = value ?? 'Minutes';
    notifyListeners();
  }

  // Data fetching methods
  Future<void> fetchBranchData(BuildContext context, BranchProvider branchProvider) async {
    print('RegistrationProvider: Fetching branch data');
    try {
      await branchProvider.fetchBranchData(context);
      
      if (branchProvider.branches != null) {
        // Extract unique locations from branches
        Set<String> uniqueLocations = {};
        List<String> branchNames = [];
        
        for (var branch in branchProvider.branches!) {
          if (branch.location != null) {
            uniqueLocations.add(branch.location!);
          }
          if (branch.name != null) {
            branchNames.add(branch.name!);
          }
        }
        
        locations = uniqueLocations.toList();
        branches = branchNames;
        
        print('RegistrationProvider: Branch data processed - ${locations.length} locations, ${branches.length} branches');
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
        availableTreatments = treatmentProvider.treatments
            .where((treatment) => treatment.isActive == true && treatment.name != null)
            .map((treatment) => treatment.name!)
            .toList();
        
        print('RegistrationProvider: Treatment data processed - ${availableTreatments.length} active treatments');
        notifyListeners();
      }
    } catch (e) {
      print('RegistrationProvider: Error fetching treatment data - $e');
    }
  }

  // Method to filter branches based on selected location
  List<String> getFilteredBranches(BranchProvider branchProvider) {
    if (selectedLocation == null || branchProvider.branches == null) {
      return branches;
    }
    
    List<String> filteredBranches = [];
    for (var branch in branchProvider.branches!) {
      if (branch.location == selectedLocation && branch.name != null) {
        filteredBranches.add(branch.name!);
      }
    }
    
    print('RegistrationProvider: Filtered branches for location "$selectedLocation": ${filteredBranches.length} branches');
    return filteredBranches;
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
    selectedTreatment = value;
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
    selectedHour = 'Hour';
    selectedMinute = 'Minutes';
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
