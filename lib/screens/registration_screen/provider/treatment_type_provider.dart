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
}
