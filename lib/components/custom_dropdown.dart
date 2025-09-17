import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  // Common properties
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  // Style type properties
  final CustomDropdownStyle style;
  
  // For inline style (original)
  final String? label;
  
  // For field style (new)
  final String? hintText;
  final String? labelText;

  const CustomDropdown({
    super.key,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.style = CustomDropdownStyle.inline,
    this.label,
    this.hintText,
    this.labelText,
  });

  // Factory constructor for inline style (original usage)
  factory CustomDropdown.inline({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String label,
    String? Function(String?)? validator,
  }) {
    return CustomDropdown(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: CustomDropdownStyle.inline,
      label: label,
    );
  }

  // Factory constructor for field style (new usage)
  factory CustomDropdown.field({
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? hintText,
    String? labelText,
    String? Function(String?)? validator,
  }) {
    return CustomDropdown(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: CustomDropdownStyle.field,
      hintText: hintText,
      labelText: labelText,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case CustomDropdownStyle.inline:
        return _buildInlineDropdown();
      case CustomDropdownStyle.field:
        return _buildFieldDropdown();
    }
  }

  // Original inline dropdown design
  Widget _buildInlineDropdown() {
    return Row(
      children: [
        Text(
          '$label : ',
          style: TextStyleClass.bodyMedium(ColorClass.primaryText),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: ColorClass.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ColorClass.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: ColorClass.primaryColor,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: SizedBox(
                      width: 150, // Fixed width for inline dropdown
                      child: Text(
                        item,
                        style: TextStyleClass.bodyMedium(ColorClass.primaryText),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // New field dropdown design (like TextFormField)
  Widget _buildFieldDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyleClass.bodyLarge(ColorClass.primaryText),
          ),
          const SizedBox(height: 6),
        ],
        Material(
          color: Colors.transparent,
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              
              hintText: hintText,
              hintStyle: TextStyleClass.lightMedium(ColorClass.black.withValues(alpha: 0.4)),
              filled: true,
              fillColor: ColorClass.grey.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorClass.black.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorClass.black.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorClass.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: SizedBox(
                  width: 200, // Fixed width to prevent overflow
                  child: Text(
                    item,
                    style: TextStyleClass.buttonLarge(ColorClass.primaryText),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: ColorClass.primaryColor,
            ),
            style: TextStyleClass.buttonLarge(ColorClass.primaryText),
          ),
        ),
      ],
    );
  }
}

// Enum to define dropdown styles
enum CustomDropdownStyle {
  inline,  // Original style with label on the side
  field,   // New style like TextFormField
}