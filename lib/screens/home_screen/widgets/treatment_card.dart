// Treatment Card Widget
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:ayurseva/screens/home_screen/models/patient_list_model.dart';
import 'package:ayurseva/utils/app_utils.dart';
import 'package:flutter/material.dart';

class TreatmentCard extends StatelessWidget {
  final Patient booking;
  final VoidCallback onViewDetails;

  const TreatmentCard({
    Key? key,
    required this.booking,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorClass.primaryText.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with number and name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${booking.id}. ',
                style: TextStyleClass.poppinsMedium(16, ColorClass.primaryText),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.name??"--",
                      style: TextStyleClass.poppinsMedium(16, ColorClass.primaryText),
                    ),
                    const SizedBox(height: 4),
                      Text(
                       booking.patientdetailsSet?.isNotEmpty == true 
                           ? booking.patientdetailsSet![0].treatmentName ?? "--"
                           : "--",
                        style: TextStyleClass.bodyMedium(ColorClass.primaryColor),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Date and Booked by info
          Row(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppUtils.formatDate(booking.dateNdTime),
                    style: TextStyleClass.bodySmall(Colors.orange),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    booking.user??"--",
                    style: TextStyleClass.bodySmall(Colors.orange),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // View booking details button
          GestureDetector(
            onTap: onViewDetails,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: ColorClass.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColorClass.primaryText.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Booking details',
                    style: TextStyleClass.bodyMedium(ColorClass.primaryText),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: ColorClass.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}