import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ayurseva/constants/color_class.dart';

class TreatmentListShimmer extends StatelessWidget {
  const TreatmentListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 6, // Show 6 shimmer cards
        itemBuilder: (context, index) => const TreatmentCardShimmer(),
      ),
    );
  }
}

class TreatmentCardShimmer extends StatelessWidget {
  const TreatmentCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorClass.primaryText.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with number and name shimmer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number shimmer (like "1. ")
              Container(
                height: 20,
                width: 25,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient name shimmer
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Treatment name shimmer
                    Container(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Date and Booked by info shimmer
          Row(
            children: [
              // Date section
              Row(
                children: [
                  // Calendar icon shimmer
                  Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Date text shimmer
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Booked by section
              Row(
                children: [
                  // Person icon shimmer
                  Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // User name shimmer
                  Container(
                    height: 14,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // View booking details button shimmer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: ColorClass.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ColorClass.primaryText.withValues(alpha: 0.1),
              ),
            ),
            
          ),
        ],
      ),
    );
  }
}
