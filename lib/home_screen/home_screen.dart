import 'package:ayurseva/components/custom_dropdown.dart';
import 'package:ayurseva/components/custom_searchbar.dart';
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:ayurseva/home_screen/widgets/treatment_card.dart';
import 'package:ayurseva/login_screen/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
class TreatmentBooking {
  final int id;
  final String customerName;
  final String treatmentName;
  final String date;
  final String bookedBy;

  TreatmentBooking({
    required this.id,
    required this.customerName,
    required this.treatmentName,
    required this.date,
    required this.bookedBy,
  });
}

// Main Screen
class TreatmentsListScreen extends StatefulWidget {
  const TreatmentsListScreen({super.key});

  @override
  State<TreatmentsListScreen> createState() => _TreatmentsListScreenState();
}

class _TreatmentsListScreenState extends State<TreatmentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSortBy = 'Date';
  final List<String> _sortOptions = ['Date', 'Name', 'Treatment'];

  // Sample data
  final List<TreatmentBooking> _treatments = [
    TreatmentBooking(
      id: 1,
      customerName: 'Vikram Singh',
      treatmentName: 'Couple Combo Package (Rejuven...',
      date: '31/01/2024',
      bookedBy: 'Jithesh',
    ),
    TreatmentBooking(
      id: 2,
      customerName: 'Vikram Singh',
      treatmentName: 'Couple Combo Package (Rejuven...',
      date: '31/01/2024',
      bookedBy: 'Jithesh',
    ),
    TreatmentBooking(
      id: 3,
      customerName: 'Vikram Singh',
      treatmentName: 'Couple Combo Package (Rejuven...',
      date: '31/01/2024',
      bookedBy: 'Jithesh',
    ),
    TreatmentBooking(
      id: 4,
      customerName: 'Vikram Singh',
      treatmentName: 'Couple Combo Package (Rejuven...',
      date: '31/01/2024',
      bookedBy: 'Jithesh',
    ),
  ];

  List<TreatmentBooking> _filteredTreatments = [];

  @override
  void initState() {
    super.initState();
    _filteredTreatments = _treatments;
  }

  void _handleSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTreatments =
          _treatments.where((treatment) {
            return treatment.customerName.toLowerCase().contains(query) ||
                treatment.treatmentName.toLowerCase().contains(query) ||
                treatment.bookedBy.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _handleSortChange(String? value) {
    if (value != null) {
      setState(() {
        _selectedSortBy = value;
        // Add sorting logic here based on the selected option
      });
    }
  }

  void _handleViewBookingDetails(TreatmentBooking booking) {
    // Navigate to booking details screen
    print('View details for booking ${booking.id}');
  }

  void _handleRegisterNow() {
    // Navigate to registration screen
    print('Register Now clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logout button and notification
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logout button
                  GestureDetector(
                    onTap: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorClass.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout,
                            color: ColorClass.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Logout',
                            style: TextStyleClass.bodySmall(ColorClass.white),
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
                onSearchPressed: _handleSearch,
                onChanged: (_) => _handleSearch(),
              ),
            ),

            const SizedBox(height: 20),

            // Sort By Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomDropdown(
                  value: _selectedSortBy,
                  items: _sortOptions,
                  onChanged: _handleSortChange,
                  label: 'Sort by',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Treatments List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredTreatments.length,
                itemBuilder: (context, index) {
                  final treatment = _filteredTreatments[index];
                  return TreatmentCard(
                    booking: treatment,
                    onViewDetails: () => _handleViewBookingDetails(treatment),
                  );
                },
              ),
            ),

            // Register Now Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleRegisterNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorClass.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Register Now',
                    style: TextStyleClass.buttonLarge(ColorClass.white),
                  ),
                ),
              ),
            ),
          ],
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
