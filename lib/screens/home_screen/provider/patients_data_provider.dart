import 'package:ayurseva/constants/api_urls.dart';
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/screens/home_screen/models/patient_list_model.dart';
import 'package:ayurseva/utils/get_service_utils.dart';
import 'package:ayurseva/utils/app_utils.dart';
import 'package:ayurseva/utils/pdf_generator.dart';
import 'package:flutter/material.dart';

class PatientsDataProvider extends ChangeNotifier {
  bool isLoading = false;
  PatientListModel? patientListModel;
  List<Patient> patientResponseList = [];
  List<Patient> filteredPatients = [];
  
  // Search and sort properties
  String searchQuery = '';
  String selectedSortBy = 'Date';
  final List<String> sortOptions = ['Date', 'Name', 'Treatment'];

  Future<void> fetchPatientsData(BuildContext context) async {
    patientListModel = null;
    patientResponseList.clear();
    filteredPatients.clear();
    setLoading(true);

    try {
      final jsonData =
          await GetServiceUtils.fetchData(ApiUrls.getPatientsData(), context);

      patientListModel = patientListModelFromJson(jsonData);
      patientResponseList = patientListModel!.patient ?? [];
      
      // Initialize filtered list with all patients
      filteredPatients = List.from(patientResponseList);
      
      // Apply current search and sort
      _applySearchAndSort();

      debugPrint("Patients fetched successfully");
      debugPrint("Parsed JSON Data: $jsonData");
      setLoading(false);
    } catch (e, stackTrace) {
      debugPrint('Patients Data Error: $e');
      debugPrint('Stack trace: $stackTrace');
      setLoading(false);
    }
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void searchPatients(String query) {
    searchQuery = query.toLowerCase().trim();
    _applySearchAndSort();
    notifyListeners();
  }

  void updateSortBy(String? sortBy) {
    if (sortBy != null) {
      selectedSortBy = sortBy;
      _applySearchAndSort();
      notifyListeners();
    }
  }

  void _applySearchAndSort() {
    // Start with all patients
    List<Patient> tempList = List.from(patientResponseList);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      tempList = tempList.where((patient) {
        final name = patient.name?.toLowerCase() ?? '';
        final phone = patient.phone?.toLowerCase() ?? '';
        final address = patient.address?.toLowerCase() ?? '';
        final user = patient.user?.toLowerCase() ?? '';
        
        // Search in treatment names from patientdetails_set
        final treatmentNames = patient.patientdetailsSet
            ?.map((detail) => detail.treatmentName?.toLowerCase() ?? '')
            .join(' ') ?? '';

        return name.contains(searchQuery) ||
               phone.contains(searchQuery) ||
               address.contains(searchQuery) ||
               user.contains(searchQuery) ||
               treatmentNames.contains(searchQuery);
      }).toList();
    }

    // Apply sorting
    switch (selectedSortBy) {
      case 'Name':
        tempList.sort((a, b) {
          final nameA = a.name ?? '';
          final nameB = b.name ?? '';
          return nameA.compareTo(nameB);
        });
        break;
      case 'Treatment':
        tempList.sort((a, b) {
          final treatmentA = a.patientdetailsSet?.isNotEmpty == true 
              ? a.patientdetailsSet!.first.treatmentName ?? ''
              : '';
          final treatmentB = b.patientdetailsSet?.isNotEmpty == true 
              ? b.patientdetailsSet!.first.treatmentName ?? ''
              : '';
          return treatmentA.compareTo(treatmentB);
        });
        break;
      case 'Date':
      default:
        tempList.sort((a, b) {
          final dateA = a.dateNdTime ?? DateTime.now();
          final dateB = b.dateNdTime ?? DateTime.now();
          return dateB.compareTo(dateA); // Latest first
        });
        break;
    }

    filteredPatients = tempList;
  }

  void clearSearch() {
    searchQuery = '';
    _applySearchAndSort();
    notifyListeners();
  }

  void refreshData(BuildContext context) {
    fetchPatientsData(context);
  }

  // Helper methods for UI
  int get totalPatients => patientResponseList.length;
  int get filteredPatientsCount => filteredPatients.length;
  bool get hasSearchResults => filteredPatients.isNotEmpty;
  bool get isSearching => searchQuery.isNotEmpty;

  // Convert Patient data to InvoiceData for PDF generation
  InvoiceData convertPatientToInvoiceData(Patient patient) {
    debugPrint('PatientsDataProvider: Converting patient ${patient.id} to invoice data');
    
    // Parse date and time using AppUtils
    String treatmentDate = AppUtils.formatDate(patient.dateNdTime);
    String treatmentTime = AppUtils.formatTreatmentTime(patient.dateNdTime);
    String bookedOn = AppUtils.formatBookingDateTime(patient.createdAt);
    
    // Convert treatments
    List<TreatmentItem> treatmentItems = [];
    if (patient.patientdetailsSet != null && patient.patientdetailsSet!.isNotEmpty) {
      for (var detail in patient.patientdetailsSet!) {
        final maleCount = int.tryParse(detail.male ?? '0') ?? 0;
        final femaleCount = int.tryParse(detail.female ?? '0') ?? 0;
        final price = double.tryParse(patient.price?.toString() ?? '0') ?? 0.0;
        final total = price * (maleCount + femaleCount);
        
        treatmentItems.add(TreatmentItem(
          name: detail.treatmentName ?? 'Unknown Treatment',
          price: price,
          maleCount: maleCount,
          femaleCount: femaleCount,
          total: total,
        ));
      }
    }
    
    // Get branch information
    String branchName = 'Unknown Branch';
    String address = 'Cheepunkal P.O. Kumarakom, Kottayam, Kerala - 686563';
    String gstNumber = '32AABCU9603R1ZW';
    
    if (patient.branch != null) {
      branchName = patient.branch!.name?.name ?? 'Unknown Branch';
      if (patient.branch!.address != null) {
        // Convert enum to string
        address = patient.branch!.address.toString().split('.').last.replaceAll('_', ', ');
      }
      gstNumber = patient.branch!.gst ?? gstNumber;
    }
    
    return InvoiceData(
      companyName: 'Amruta Ayurveda',
      branchName: branchName,
      address: address,
      email: 'unknown@gmail.com',
      phone: '+91 9876543210 | +91 9786543210',
      gstNumber: gstNumber,
      patientName: patient.name ?? 'Unknown Patient',
      patientAddress: patient.address ?? 'No address provided',
      patientWhatsApp: patient.phone ?? 'No phone provided',
      bookedOn: bookedOn,
      treatmentDate: treatmentDate,
      treatmentTime: treatmentTime,
      treatments: treatmentItems,
      totalAmount: patient.totalAmount?.toDouble() ?? 0.0,
      discount: patient.discountAmount?.toDouble() ?? 0.0,
      advance: patient.advanceAmount?.toDouble() ?? 0.0,
      balance: patient.balanceAmount?.toDouble() ?? 0.0,
      thankYouMessage: 'Thank you for choosing us',
      footerNote: 'Booking amount is non-refundable, and it\'s important to arrive on the allotted time for your treatment',
    );
  }

  // Show invoice for selected patient
  void showPatientInvoice(BuildContext context, Patient patient) {
    debugPrint('PatientsDataProvider: Showing invoice for patient ${patient.id}');
    
    try {
      final invoiceData = convertPatientToInvoiceData(patient);
      InvoiceGenerator.generateAndShowInvoice(context, invoiceData);
    } catch (e) {
      debugPrint('PatientsDataProvider: Error showing invoice - $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle sort change with user feedback
  void handleSortChange(BuildContext context, String? value) {
    if (value != null) {
      debugPrint('PatientsDataProvider: Sorting by $value');
      updateSortBy(value);
      
      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sorted by $value'),
          duration: const Duration(seconds: 1),
          backgroundColor: ColorClass.primaryColor,
        ),
      );
    }
  }

  // Clear search with controller reset
  void clearSearchWithController(BuildContext context, TextEditingController searchController) {
    debugPrint('PatientsDataProvider: Clearing search');
    clearSearch();
    searchController.clear();
  }
}