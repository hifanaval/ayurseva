import 'package:ayurseva/constants/api_urls.dart';
import 'package:ayurseva/screens/registration_screen/models/branch_list_model.dart';
import 'package:ayurseva/utils/get_service_utils.dart';
import 'package:flutter/material.dart';

class BranchProvider extends ChangeNotifier {
  bool isLoading = false;
  BranchListModel? branchListModel;
  List<BranchList>? branches;

  Future<void> fetchBranchData(BuildContext context) async {
    branchListModel = null;
    branches?.clear();
    setLoading(true);

    try {
      final jsonData = await GetServiceUtils.fetchData(
        ApiUrls.getBranchData(),
        context,
      );

      branchListModel = branchListModelFromJson(jsonData);
      branches = branchListModel!.branches ?? [];

      debugPrint("Branches fetched successfully");
      debugPrint("Parsed JSON Data: $jsonData");
      setLoading(false);
    } catch (e, stackTrace) {
      debugPrint('Branches Data Error: $e');
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
