import 'package:ayurseva/constants/api_urls.dart';
import 'package:ayurseva/home_screen/models/patient_list_model.dart';
import 'package:ayurseva/utils/get_service_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PatientsDataProvider extends ChangeNotifier {
  bool isLoading = false;
  PatientListModel? patientListModel;
  List<Patient> patientResponseList = [];

  Future<void> fetchPatientsData(BuildContext context) async {
    patientListModel = null;
    patientResponseList.clear();
    setLoading(true);

    try {
      final jsonData =
          await GetServiceUtils.fetchData(ApiUrls.getPatientsData(), context);

      patientListModel = patientListModelFromJson(jsonData);
      patientResponseList = patientListModel!.patient ?? [];

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

 
}
