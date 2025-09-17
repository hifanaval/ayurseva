import 'package:ayurseva/components/custom_button.dart';
import 'package:ayurseva/components/custom_dropdown.dart';
import 'package:ayurseva/components/custom_searchbar.dart';
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:ayurseva/screens/home_screen/provider/patients_data_provider.dart';
import 'package:ayurseva/screens/home_screen/shimmer/treatment_card_shimmer.dart';
import 'package:ayurseva/screens/home_screen/widgets/treatment_card.dart';
import 'package:ayurseva/screens/login_screen/provider/auth_provider.dart';
import 'package:ayurseva/screens/registration_screen/registration_screen.dart';
import 'package:ayurseva/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Main Screen
class TreatmentsListScreen extends StatefulWidget {
  const TreatmentsListScreen({super.key});

  @override
  State<TreatmentsListScreen> createState() => _TreatmentsListScreenState();
}

class _TreatmentsListScreenState extends State<TreatmentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
 

  


  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientsProvider = Provider.of<PatientsDataProvider>(context, listen: false);
      patientsProvider.fetchPatientsData(context);
    });
  }

  void _handleSortChange(String? value) {
    if (value != null) {
      final patientsProvider = Provider.of<PatientsDataProvider>(context, listen: false);
      patientsProvider.updateSortBy(value);
      
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
 
 

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Consumer<PatientsDataProvider>(
          builder: (context, patientsProvider, child) {
            return Column(
              children: [
                // Header with logout button and notification
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logout button
                      GestureDetector(
                        onTap: () {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          AppUtils.showLogoutConfirmation(context, () async {
                            await authProvider.logout(context);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ColorClass.primaryColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon(
                              //   Icons.logout,
                              //   color: ColorClass.primaryColor,
                              //   size: 18,
                              // ),
                              // const SizedBox(width: 4),
                              Text(
                                'Logout',
                                style: TextStyleClass.bodySmall(
                                  ColorClass.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: ColorClass.primaryText,
                            size: 24,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Search for treatments',
                   onSearchPressed: () => patientsProvider.searchPatients(_searchController.text),
                    onChanged: (query) => patientsProvider.searchPatients(query),
                  ),
                ),
            
                const SizedBox(height: 20),
            
                // Sort By Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomDropdown(
                     value: patientsProvider.selectedSortBy,
                      items: patientsProvider.sortOptions,
                      onChanged: _handleSortChange,
                      style: CustomDropdownStyle.inline,
                      label: 'Sort by',
                    ),
                  ),
                ),
            
                // Sort info
                if (patientsProvider.isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          '${patientsProvider.filteredPatientsCount} patients found',
                          style: TextStyleClass.bodySmall(ColorClass.primaryText.withValues(alpha: 0.6)),
                        ),
                        const Spacer(),
                        Text(
                          'Sorted by ${patientsProvider.selectedSortBy}',
                          style: TextStyleClass.bodySmall(ColorClass.primaryColor),
                        ),
                      ],
                    ),
                  ),
            
                const SizedBox(height: 20),
            
                // Treatments List
                Expanded(
                  child:patientsProvider.isLoading
                      ?const TreatmentListShimmer()
                      : patientsProvider.filteredPatients.isEmpty
                          ?  AppUtils.noPatientsFound()
                          : RefreshIndicator(
                              onRefresh: () => patientsProvider.fetchPatientsData(context),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: patientsProvider.filteredPatients.length,
                                itemBuilder: (context, index) {
                                  final patient = patientsProvider.filteredPatients[index];
                                  return TreatmentCard(
                                    booking: patient,
                                    onViewDetails:(){},
                                  );
                                },
                              ),
                            ),
                ),

            
                // Register Now Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomButton(
                    text: 'Register Now',
                    onPressed: () {
                      AppUtils.navigateTo(context, RegistrationScreen());
                    },
                    isLoading: false,
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
