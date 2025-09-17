import 'package:ayurseva/constants/api_urls.dart';
import 'package:ayurseva/screens/home_screen/models/patient_list_model.dart';
import 'package:ayurseva/utils/get_service_utils.dart';
import 'package:flutter/cupertino.dart';
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
}