// Custom Search Bar Widget
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearchPressed;
  final Function(String)? onChanged;
  final VoidCallback? onClearPressed;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onSearchPressed,
    this.onChanged,
    this.onClearPressed,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {}); // Rebuild when text changes
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.isNotEmpty;
    
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
              controller: widget.controller,
              onChanged: widget.onChanged,
              style: TextStyleClass.bodyMedium(ColorClass.black),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyleClass.bodyMedium(
                  ColorClass.primaryText.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: ColorClass.black.withValues(alpha: 0.5),
                ),
                suffixIcon: hasText
                    ? GestureDetector(
                        onTap: () {
                          widget.controller.clear();
                          if (widget.onClearPressed != null) {
                            widget.onClearPressed!();
                          }
                        },
                        child: Icon(
                          Icons.close,
                          color: ColorClass.black.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 40,
          width: 100,
          child: ElevatedButton(
            onPressed: widget.onSearchPressed,
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