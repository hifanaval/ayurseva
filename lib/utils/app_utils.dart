import 'dart:io';
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
      Navigator.push(context, CupertinoPageRoute(builder: (context) => widget));
    } else {
      //('Using Android-style navigation (MaterialPageRoute)');
      Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
    }
  }

  static showToast(
    BuildContext context,
    String labelText,
    String message,
    bool isSuccess,
  ) {
    toastification.show(
      context: context, // optional if you use ToastificationWrapper

      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        labelText,
        style: TextStyleClass.poppinsSemiBold(
          14,
          isSuccess ? ColorClass.primaryColor : ColorClass.redError,
        ),
      ),
      description: Text(
        message,
        style: TextStyleClass.poppinsSemiBold(12, ColorClass.primaryText),
      ),
      alignment: Alignment.bottomCenter,
      animationDuration: const Duration(milliseconds: 500),

      icon: Icon(
        isSuccess ? Icons.check : Icons.error_outline_rounded,
        color: isSuccess ? ColorClass.primaryColor : ColorClass.redError,
      ),
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
      borderSide: BorderSide(color: ColorClass.grey),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      style: ToastificationStyle.minimal,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) => debugPrint('Toast ${toastItem.id} tapped'),
        onCloseButtonTap:
            (toastItem) =>
                debugPrint('Toast ${toastItem.id} close button tapped'),
        onAutoCompleteCompleted:
            (toastItem) =>
                debugPrint('Toast ${toastItem.id} auto complete completed'),
        onDismissed:
            (toastItem) => debugPrint('Toast ${toastItem.id} dismissed'),
      ),
    );
  }

  /// Show logout confirmation dialog
  static void showLogoutConfirmation(
    BuildContext context,
    VoidCallback onLogoutConfirm,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextStyleClass.poppinsSemiBold(18, ColorClass.primaryText),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyleClass.poppinsRegular(14, ColorClass.primaryText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: Text(
                'Cancel',
                style: TextStyleClass.poppinsMedium(14, ColorClass.primaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                onLogoutConfirm(); // Execute logout function
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.primaryColor,
                foregroundColor: ColorClass.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyleClass.poppinsMedium(14, ColorClass.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static String formatDate(DateTime? dateTime) {
    try {
      if (dateTime == null) return '';
      String formattedDate = DateFormat("dd/MM/yyyy").format(dateTime);
      return formattedDate;
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return '';
    }
  }

  static noPatientsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: ColorClass.primaryText.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: TextStyleClass.bodyLarge(
              ColorClass.primaryText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyleClass.bodyMedium(
              ColorClass.primaryText.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
