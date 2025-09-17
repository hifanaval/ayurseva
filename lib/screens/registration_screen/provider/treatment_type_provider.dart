import 'package:ayurseva/constants/api_urls.dart';
import 'package:ayurseva/screens/registration_screen/models/treatment_list_model.dart';
import 'package:ayurseva/utils/get_service_utils.dart';
import 'package:flutter/material.dart';

class TreatmentTypeProvider extends ChangeNotifier {
  bool isLoading = false;
  TreatmentTypeList? treatmentTypeListModel;
  List<Treatment> treatments = [];

  Future<void> fetchTreatmentData(BuildContext context) async {
    treatmentTypeListModel = null;
    treatments.clear();
    setLoading(true);

    try {
      final jsonData = await GetServiceUtils.fetchData(
        ApiUrls.getTreatmentData(),
        context,
      );

      treatmentTypeListModel = treatmentTypeListFromJson(jsonData);
      treatments = treatmentTypeListModel!.treatments ?? [];

      debugPrint("Treatments fetched successfully");
      debugPrint("Parsed JSON Data: $jsonData");
      setLoading(false);
    } catch (e, stackTrace) {
      debugPrint('Treatments Data Error: $e');
      debugPrint('Stack trace: $stackTrace');
      setLoading(false);
    }
    notifyListeners();
  }

  setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Gets all active treatment names
  List<String> getActiveTreatmentNames() {
    return treatments
        .where((treatment) => treatment.isActive == true && treatment.name != null)
        .map((treatment) => treatment.name!)
        .toSet() // Remove duplicates
        .toList();
  }

  /// Gets all treatment names (active and inactive)
  List<String> getAllTreatmentNames() {
    return treatments
        .where((treatment) => treatment.name != null)
        .map((treatment) => treatment.name!)
        .toSet() // Remove duplicates
        .toList();
  }

  /// Finds a treatment by name
  Treatment? findTreatmentByName(String treatmentName) {
    try {
      return treatments.firstWhere((treatment) => treatment.name == treatmentName);
    } catch (e) {
      return null;
    }
  }

  /// Gets treatment ID by name
  String? getTreatmentIdByName(String treatmentName) {
    final treatment = findTreatmentByName(treatmentName);
    return treatment?.id?.toString();
  }

  /// Checks if a treatment name is valid and active
  bool isValidActiveTreatment(String treatmentName) {
    return treatments.any((treatment) => 
        treatment.name == treatmentName && 
        treatment.isActive == true);
  }
}
