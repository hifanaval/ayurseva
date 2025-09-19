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
      final patientsProvider = Provider.of<PatientsDataProvider>(
        context,
        listen: false,
      );
      // Clear any existing search when returning to the screen
      patientsProvider.clearSearchWithController(context, _searchController);
      // Fetch fresh data
      patientsProvider.fetchPatientsData(context);
    });
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Logout button
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
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          AppUtils.showLogoutConfirmation(context, () async {
                            await authProvider.logout(context);
                          });
                        },
                        child: Icon(
                          Icons.logout,
                          color: ColorClass.black,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:                   CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Search for treatments',
                    onSearchPressed:
                        () => patientsProvider.searchPatients(
                          _searchController.text,
                        ),
                    onChanged:
                        (query) => patientsProvider.searchPatients(query),
                    onClearPressed: () => patientsProvider.clearSearchWithController(context, _searchController),
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
                      onChanged: (value) => patientsProvider.handleSortChange(context, value),
                      style: CustomDropdownStyle.inline,
                      label: 'Sort by',
                    ),
                  ),
                ),

                // Sort info
                if (patientsProvider.isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${patientsProvider.filteredPatientsCount} patients found',
                          style: TextStyleClass.bodySmall(
                            ColorClass.primaryText.withValues(alpha: 0.6),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Sorted by ${patientsProvider.selectedSortBy}',
                          style: TextStyleClass.bodySmall(
                            ColorClass.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Treatments List
                Expanded(
                  child:
                      patientsProvider.isLoading
                          ? const TreatmentListShimmer()
                          : patientsProvider.filteredPatients.isEmpty
                          ? AppUtils.noPatientsFound()
                          : RefreshIndicator(
                            onRefresh:
                                () =>
                                    patientsProvider.fetchPatientsData(context),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount:
                                  patientsProvider.filteredPatients.length,
                              itemBuilder: (context, index) {
                                final patient =
                                    patientsProvider.filteredPatients[index];
                                return TreatmentCard(
                                  booking: patient,
                                  onViewDetails:
                                      () => patientsProvider.showPatientInvoice(
                                        context,
                                        patient,
                                      ),
                                );
                              },
                            ),
                          ),
                ),

                // Register Now Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
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
          },
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
