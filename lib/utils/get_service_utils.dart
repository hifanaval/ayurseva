// get_service_util.dart
import 'package:ayurseva/constants/string_class.dart';
import 'package:ayurseva/utils/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetServiceUtils {
  // Get token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StringClass.token);
  }

  // Get headers with token
  static Future<Map<String, String>> get _getHeaders async {
    final token = await _getToken();
    if (token == null) {
      throw NetworkException('Login expired. Please login again.');
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // Main fetch method
  static Future<String> fetchData(String url, BuildContext context) async {
    try {
      if (!kIsWeb) {
        await _checkConnectivity();
      }

      final headers = await _getHeaders;
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return await _handleResponse(response, context, url);
    } on NetworkException catch (e) {
      _handleException(context, e);
      rethrow;
    } catch (e) {
      final error = NetworkException('An unexpected error occurred: $e');
      _handleException(context, error);
      throw error;
    }
  }

  // Custom exception handler
  static void _handleException(BuildContext context, NetworkException error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  // Handle HTTP response
  static Future<String> _handleResponse(
    http.Response response,
    BuildContext context,
    String url,
  ) async {
    switch (response.statusCode) {
      case 200:
        if (kDebugMode) {
          debugPrint('$url: ${response.body}');
        }
        return response.body;
  
      case 403:
        throw NetworkException('Access forbidden', response.statusCode);
      case 500:
        throw NetworkException(
            'Server error: Bad Gateway', response.statusCode);
      default:
        throw NetworkException(
          'Request failed with status: ${response.statusCode}',
          response.statusCode,
        );
    }
  }

 

  // Check network connectivity
  static Future<void> _checkConnectivity() async {
    if (!await AppUtils.hasInternet()) {
      throw NetworkException('No internet connection');
    }
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StringClass.token, token);
  }

  // Clear token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StringClass.token);
  }
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'NetworkException: $message${statusCode != null ? ' (Status Code: $statusCode)' : ''}';
}
