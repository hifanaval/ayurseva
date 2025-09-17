import 'dart:io';
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

class AppUtils {


 ///To check internet connection
  static Future<bool> hasInternet() async {
    try {
      final url = Uri.parse('https://www.google.com');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      return false; // Request failed, so no internet connection
    }
  }

  /// Navigate to a new screen/widget with automatic platform detection
  static void navigateTo(BuildContext context, Widget widget) {
    
    if (Platform.isIOS) {
      //('Using iOS-style navigation (CupertinoPageRoute)');
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => widget),
      );
    } else {
      //('Using Android-style navigation (MaterialPageRoute)');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => widget),
      );
    }
  }

  static showToast(
      BuildContext context, String labelText, String message, bool isSuccess) {
    toastification.show(
      context: context, // optional if you use ToastificationWrapper

      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        labelText,
        style: TextStyleClass.poppinsSemiBold(
            14, isSuccess ? ColorClass.primaryColor : ColorClass.redError),
      ),
      description: Text(
        message,
        style: TextStyleClass.poppinsSemiBold(12, ColorClass.primaryText),
      ),
      alignment: Alignment.bottomCenter,
      animationDuration: const Duration(milliseconds: 500),

      icon: Icon(isSuccess ? Icons.check : Icons.error_outline_rounded,
          color: isSuccess ? ColorClass.primaryColor : ColorClass.redError),
      showIcon: true, // show or hide the icon
      primaryColor: isSuccess ? ColorClass.primaryColor : ColorClass.redError,
      backgroundColor: ColorClass.white,
      // foregroundColor: const Color.fromARGB(255, 77, 70, 70),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.transparent,
          blurRadius: 0,
          offset: Offset(0, 0),
          spreadRadius: 0,
        ),
      ],
      borderSide:  BorderSide(color: ColorClass.grey),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      style: ToastificationStyle.minimal,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) => debugPrint('Toast ${toastItem.id} tapped'),
        onCloseButtonTap: (toastItem) =>
            debugPrint('Toast ${toastItem.id} close button tapped'),
        onAutoCompleteCompleted: (toastItem) =>
            debugPrint('Toast ${toastItem.id} auto complete completed'),
        onDismissed: (toastItem) =>
            debugPrint('Toast ${toastItem.id} dismissed'),
      ),
    );

}}