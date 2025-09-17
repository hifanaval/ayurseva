import 'package:flutter/material.dart';

class TextStyleClass {
  // Font family constants
  static const String poppins = 'Poppins';
  
  // Default font family - you can change this to switch the entire app's font
  static const String defaultFontFamily = poppins;

  // Poppins Font Styles with customizable color
  static TextStyle poppinsLight(double fontSize, Color color) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: color,
    );
  }

  // Poppins Font Styles with customizable color
  static TextStyle poppinsRegular(double fontSize, Color color) {
    return TextStyle(
      fontFamily:  poppins,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle poppinsMedium(double fontSize, Color color, ) {
    return TextStyle(
      fontFamily:  poppins,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle poppinsSemiBold(double fontSize, Color color, ) {
    return TextStyle(
      fontFamily:  poppins,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle poppinsBold(double fontSize, Color color, ) {
    return TextStyle(
      fontFamily:  poppins,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  

  // Utility methods for common text styles
  static TextStyle heading1(Color color, ) {
    return poppinsBold(24, color, );
  }

  static TextStyle heading2(Color color, ) {
    return poppinsBold(20, color, );
  }

  static TextStyle heading3(Color color, ) {
    return poppinsSemiBold(18, color, );
  }

  static TextStyle heading4(Color color, ) {
    return poppinsSemiBold(16, color, );
  }

  static TextStyle bodyLarge(Color color, ) {
    return poppinsRegular(16, color, );
  }

  static TextStyle bodyMedium(Color color, ) {
    return poppinsRegular(14, color, );
  }

  static TextStyle bodySmall(Color color, ) {
    return poppinsRegular(12, color, );
  }

  static TextStyle caption(Color color, ) {
    return poppinsRegular(10, color, );
  }

   // Light text styles for subtle content
  static TextStyle lightLarge(Color color) {
    return poppinsLight(16, color);
  }

  static TextStyle lightMedium(Color color) {
    return poppinsLight(14, color);
  }

  static TextStyle lightSmall(Color color) {
    return poppinsLight(12, color);
  }

  static TextStyle lightCaption(Color color) {
    return poppinsLight(10, color);
  }

  // Button text styles
  static TextStyle buttonLarge(Color color, ) {
    return poppinsSemiBold(16, color, );
  }

  static TextStyle buttonMedium(Color color, ) {
    return poppinsMedium(14, color, );
  }

  static TextStyle buttonSmall(Color color, ) {
    return poppinsMedium(12, color, );
  }

  // Custom method with all parameters
  static TextStyle custom({
    required double fontSize,
    required Color color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return TextStyle(
       fontFamily: defaultFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
}