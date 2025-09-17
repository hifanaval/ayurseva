// Custom Search Bar Widget
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearchPressed;
  final Function(String)? onChanged;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onSearchPressed,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: ColorClass.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorClass.black.withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyleClass.bodyMedium(ColorClass.black),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyleClass.bodyMedium(
                  ColorClass.primaryText.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: ColorClass.black.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(
                  12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 40,
          width: 100,
          child: ElevatedButton(
            onPressed: onSearchPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorClass.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Search',
              style: TextStyleClass.buttonMedium(ColorClass.white),
            ),
          ),
        ),
      ],
    );
  }
}