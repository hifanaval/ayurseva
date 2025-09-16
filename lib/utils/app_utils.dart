import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    print('AppUtils: Navigating to new screen with platform-specific animation');
    
    if (Platform.isIOS) {
      print('AppUtils: Using iOS-style navigation (CupertinoPageRoute)');
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => widget),
      );
    } else {
      print('AppUtils: Using Android-style navigation (MaterialPageRoute)');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => widget),
      );
    }
  }

}