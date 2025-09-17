import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:flutter/material.dart';


// Reusable Custom TextFormField Widget
class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.contentPadding,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyleClass.bodyLarge(ColorClass.primaryText),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _isObscured : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyleClass.lightMedium(ColorClass.black.withValues(alpha: 0.4)),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: ColorClass.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : widget.suffixIcon,
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
            contentPadding: widget.contentPadding ?? 
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyleClass.buttonLarge(ColorClass.primaryText),
        ),
      ],
    );
  }
}