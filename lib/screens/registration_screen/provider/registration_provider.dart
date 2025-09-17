import 'package:flutter/material.dart';
import 'package:ayurseva/screens/registration_screen/registration_screen.dart';
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

  // Sample data
  final List<String> locations = ['Location 1', 'Location 2', 'Location 3'];
  final List<String> branches = ['Branch 1', 'Branch 2', 'Branch 3'];
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
    selectedLocation = value;
    notifyListeners();
  }

  void updateBranch(String? value) {
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

  // Treatment methods
  void updateSelectedTreatments(List<Treatment> treatments) {
    selectedTreatments = treatments;
    notifyListeners();
  }

  void removeTreatment(int index) {
    selectedTreatments.removeAt(index);
    notifyListeners();
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
